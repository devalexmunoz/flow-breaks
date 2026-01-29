<?php

namespace App\Flow\Handlers;

use App\Flow\FlowEventHandler;
use App\Models\BreakPool;
use App\Models\BreakPoolSpot;
use Illuminate\Support\Facades\Log;

class SpotPurchasedHandler implements FlowEventHandler
{
    public function handle(array $data, int $blockHeight): void
    {
        $pool = BreakPool::where('on_chain_id', $data['breakId'])->first();

        if (! $pool) {
            Log::warning("SpotPurchased event received for unknown Break ID: {$data['breakId']}");

            return;
        }

        $spot = BreakPoolSpot::create([
            'break_pool_id' => $pool->id,
            'buyer_address' => $data['buyer'],
            'spot_index' => $data['spotIndex'],
        ]);

        Log::info("Spot sold in Pool #{$pool->on_chain_id} to {$data['buyer']}");
    }
}
