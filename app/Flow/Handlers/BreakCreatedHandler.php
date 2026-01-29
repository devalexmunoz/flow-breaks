<?php

namespace App\Flow\Handlers;

use App\Flow\FlowEventHandler;
use App\Models\BreakPool;
use Illuminate\Support\Facades\Log;

class BreakCreatedHandler implements FlowEventHandler
{
    public function handle(array $data, int $blockHeight): void
    {
        Log::info('Handling BreakCreated for ID: '.$data['breakId']);

        $pool = BreakPool::updateOrCreate(
            ['on_chain_id' => $data['breakId']],
            [
                'host_address' => $data['host'],
                'price' => $data['price'],
                'total_spots' => $data['totalSpots'],
                'status' => 'OPEN',
            ]
        );

        Log::info("✅ Synced Break Pool #{$pool->id}");
    }
}
