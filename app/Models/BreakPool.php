<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BreakPool extends Model
{
    public const STATUS_MAP = [
        0 => 'OPEN',
        1 => 'FILLED',
        2 => 'RANDOMIZED',
        3 => 'COMPLETED',
    ];

    protected $fillable = [
        'on_chain_id',
        'host_address',
        'name',
        'title',
        'price',
        'total_spots',
        'status',
    ];

    /**
     * Get the spots associated with this pool.
     */
    public function spots(): HasMany
    {
        return $this->hasMany(BreakPoolSpot::class);
    }
}
