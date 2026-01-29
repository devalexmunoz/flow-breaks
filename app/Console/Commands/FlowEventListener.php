<?php

namespace App\Console\Commands;

use App\Models\FlowBlockCursor;
use App\Services\FlowService;
use Illuminate\Console\Command;

class FlowEventListener extends Command
{
    protected const BLOCK_CHUNK_SIZE = 50;

    protected const POLLING_INTERVAL = 2;

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'flow:listen';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Worker that listens for Flow blockchain events';

    protected FlowService $flowService;

    public function __construct(FlowService $flowService)
    {
        parent::__construct();
        $this->flowService = $flowService;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Sarting Flow Event Listener...');

        $eventMap = $this->buildEventMap();

        if (empty($eventMap)) {
            $this->error('No events configured in config/flow.php');

            return;
        }

        while (true) {
            try {
                $this->scanLoop($eventMap);
                sleep(self::POLLING_INTERVAL);
            } catch (Exception $e) {
                $this->error('Error: '.$e->getMessage());
                sleep(5);
            }
        }
    }

    private function buildEventMap(): array
    {
        $map = [];
        $configuredEvents = config('flow.events', []);

        foreach ($configuredEvents as $shortName => $handlerClass) {
            [$contractName, $eventName] = explode('.', $shortName);

            $address = config("services.flow.contracts.$contractName");

            if (! $address) {
                $this->error("Address for contract '$contractName' not found in services config.");

                continue;
            }

            $cleanAddress = str_replace('0x', '', $address);
            $fullEventId = "A.{$cleanAddress}.{$contractName}.{$eventName}";

            $map[$fullEventId] = $handlerClass;
            $this->info("   Tracking: $shortName");
        }

        return $map;
    }

    private function scanLoop(array $eventMap)
    {
        $latestBlockHeight = $this->flowService->getLatestBlockHeight();

        foreach ($eventMap as $eventName => $handlerClass) {

            $cursor = FlowBlockCursor::firstOrCreate(
                ['event_name' => $eventName],
                ['current_height' => 0]
            );

            $start = $cursor->current_height + 1;

            if ($start > $latestBlockHeight) {
                continue;
            }

            $end = min($start + self::BLOCK_CHUNK_SIZE, $latestBlockHeight);

            $blocks = $this->flowService->getEvents($eventName, $start, $end);

            foreach ($blocks as $block) {
                if (! empty($block['events'])) {
                    foreach ($block['events'] as $event) {
                        $this->info("Event Found: $eventName (Block {$block['block_height']})");

                        $handler = app($handlerClass);
                        $handler->handle($event['data'], $block['block_height']);
                    }
                }
            }

            $cursor->update(['current_height' => $end]);
        }
    }
}
