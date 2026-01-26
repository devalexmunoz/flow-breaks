<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('break_pool_spots', function (Blueprint $table) {
            $table->id();

            $table->foreignId('break_pool_id')->constrained()->cascadeOnDelete();

            $table->unsignedInteger('spot_index');
            $table->string('buyer_address');

            $table->timestamps();

            $table->unique(['break_pool_id', 'spot_index']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('break_pool_spots');
    }
};
