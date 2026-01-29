<?php

namespace App\Services;

use Exception;
use Illuminate\Support\Facades\Http;

class FlowService
{
    protected string $baseUrl;

    /**
     * Create a new service instance and configure the Base URL.
     */
    public function __construct()
    {
        $accessNode = rtrim(config('services.flow.access_node'), '/');
        $this->baseUrl = $accessNode.'/v1';
    }

    /**
     * Check if the Flow Access Node is reachable.
     */
    public function ping(): bool
    {
        try {
            return Http::timeout(1)->get($this->baseUrl.'/blocks?height=sealed')->successful();
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * Get the latest sealed block height from the Flow blockchain.
     *
     * @return int The latest block height
     *
     * @throws Exception
     */
    public function getLatestBlockHeight(): int
    {
        $response = Http::retry(3, 100)->get($this->baseUrl.'/blocks?height=sealed');

        if ($response->failed()) {
            throw new Exception('Could not fetch latest block.');
        }

        return $response->json()[0]['header']['height'] ?? 0;
    }

    /**
     * Fetch events from the blockchain for a specific block range.
     * Automatically decodes event payloads into clean PHP arrays.
     *
     * * @param string $eventType   The event identifier (e.g. A.{addr}.Contract.EventName)
     * @param  int  $startHeight  The block height to start scanning from
     * @param  int  $endHeight  The block height to stop scanning at
     * @return array List of blocks containing the events
     *
     * @throws Exception
     */
    public function getEvents(string $eventType, int $startHeight, int $endHeight): array
    {
        $response = Http::retry(3, 100)->get($this->baseUrl.'/events', [
            'type' => $eventType,
            'start_height' => $startHeight,
            'end_height' => $endHeight,
        ]);

        if ($response->failed()) {
            throw new Exception('Flow API Error: '.$response->body());
        }

        $blocks = $response->json();

        foreach ($blocks as &$block) {
            if (isset($block['events'])) {
                foreach ($block['events'] as &$event) {
                    $rawPayload = base64_decode($event['payload']);

                    $cadenceStructure = json_decode($rawPayload, true);

                    $event['data'] = $this->parseCadenceData($cadenceStructure);

                    unset($event['payload']);
                }
            }
        }

        return $blocks;
    }

    /**
     * Run a Cadence script to read data from the blockchain.
     *
     * @param  string  $scriptContent  The raw text of the .cdc file
     * @param  array  $args  Arguments in JSON-Cadence format
     * @return mixed The decoded result
     */
    public function executeScript(string $scriptContent, array $args = []): mixed
    {
        $contracts = config('services.flow.contracts', []);

        foreach ($contracts as $contractName => $address) {
            $pattern = '/import\s+'.$contractName.'\s+from\s+["\'].*["\']/';
            $replacement = "import $contractName from $address";

            $scriptContent = preg_replace($pattern, $replacement, $scriptContent);
        }

        $payload = [
            'script' => base64_encode($scriptContent),
            'arguments' => [],
        ];

        foreach ($args as $arg) {
            $payload['arguments'][] = base64_encode(json_encode($arg));
        }

        $response = Http::post($this->baseUrl.'/scripts', $payload);

        if ($response->failed()) {
            throw new Exception('Script Execution Failed: '.$response->body());
        }

        $base64Result = $response->body();

        $cadenceStructure = json_decode(base64_decode($base64Result), true);

        return $this->parseCadenceData($cadenceStructure);
    }

    /**
     * Recursively parses Cadence JSON structure into clean PHP arrays/values.
     *
     * @param  mixed  $data  The raw Cadence response structure
     * @return mixed The clean PHP array or scalar value
     */
    private function parseCadenceData($data)
    {
        if (isset($data['type']) && in_array($data['type'], ['Event', 'Struct', 'Resource'])) {
            $clean = [];
            foreach ($data['value']['fields'] as $field) {
                $clean[$field['name']] = $this->parseCadenceData($field['value']);
            }

            return $clean;
        }

        if (isset($data['type']) && $data['type'] === 'Dictionary') {
            $clean = [];
            foreach ($data['value'] as $item) {
                $key = $this->parseCadenceData($item['key']);
                $value = $this->parseCadenceData($item['value']);
                $clean[$key] = $value;
            }

            return $clean;
        }

        if (isset($data['type']) && $data['type'] === 'Array') {
            return array_map(function ($item) {
                return $this->parseCadenceData($item);
            }, $data['value']);
        }

        if (isset($data['type']) && $data['type'] === 'Optional') {
            return $data['value'] === null ? null : $this->parseCadenceData($data['value']);
        }

        if (isset($data['value'])) {
            return $data['value'];
        }

        return $data;
    }
}
