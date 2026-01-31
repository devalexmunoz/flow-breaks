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
})->name('home');

Route::post('breaks', [App\Http\Controllers\BreakPoolController::class, 'store'])->name('breaks.store');

Route::get('create', function () {
    return Inertia::render('Create');
})->name('breaks.create');
