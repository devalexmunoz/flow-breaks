<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BreakPoolSpot extends Model
{
    protected $fillable = [
        'break_pool_id',
        'spot_index',
        'buyer_address',
    ];

    /**
     * Get the pool that owns this spot.
     */
    public function breakPool(): BelongsTo
    {
        return $this->belongsTo(BreakPool::class);
    }
}
