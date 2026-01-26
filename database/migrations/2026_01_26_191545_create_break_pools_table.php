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
        Schema::create('break_pools', function (Blueprint $table) {
            $table->id();

            $table->unsignedBigInteger('on_chain_id')->unique();

            $table->string('host_address');
            $table->string('title')->nullable();
            $table->decimal('price', 16, 8);
            $table->integer('total_spots')->default(30);
            $table->string('status')->default('OPEN');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('break_pools');
    }
};
