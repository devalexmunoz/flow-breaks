<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FlowBlockCursor extends Model
{
    protected $fillable = ['event_name', 'current_height'];
}
