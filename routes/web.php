<?php

use App\Models\BreakPool;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    $breaks = BreakPool::query()
        ->whereIn('status', [0, 1])
        ->withCount('spots')
        ->latest()
        ->get();

    return Inertia::render('Welcome', [
        'breaks' => $breaks,
    ]);
});
