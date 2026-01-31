<?php

namespace App\Http\Controllers;

use App\Models\BreakPool;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class BreakPoolController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'total_spots' => 'required|integer|min:1',
            'price' => 'required|numeric|min:0',
            'on_chain_id' => 'required|integer',
            'host_address' => 'required|string',
        ]);

        BreakPool::create([
            'name' => $validated['name'],
            'title' => $validated['name'], // Using name as title for now
            'total_spots' => $validated['total_spots'],
            'price' => $validated['price'],
            'on_chain_id' => $validated['on_chain_id'],
            'host_address' => $validated['host_address'],
            'status' => 0, // OPEN
        ]);

        return Redirect::route('home');
    }
}
