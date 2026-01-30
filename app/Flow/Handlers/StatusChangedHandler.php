<?php

namespace App\Flow\Handlers;

use App\Flow\FlowEventHandler;
use App\Models\BreakPool;
use Illuminate\Support\Facades\Log;

class StatusChangedHandler implements FlowEventHandler
{
    public function handle(array $data, int $blockHeight): void
    {
        // Event Data: { breakId: 1, status: 1 } (1 = FILLED)

        $pool = BreakPool::where('on_chain_id', $data['breakId'])->first();

        if (! $pool) {
            Log::warning("⚠️ StatusChanged for unknown Break ID: {$data['breakId']}");

            return;
        }

        // Convert Int (1) -> String ('FILLED') using the Model's map
        $rawStatus = (int) $data['status'];
        $stringStatus = BreakPool::STATUS_MAP[$rawStatus] ?? 'UNKNOWN';

        $pool->update(['status' => $stringStatus]);

        Log::info("🔄 Break #{$pool->on_chain_id} status changed to: {$stringStatus} ({$rawStatus})");
    }
}
