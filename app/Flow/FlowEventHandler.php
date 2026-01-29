<?php

namespace App\Flow;

interface FlowEventHandler
{
    /**
     * Handle a specific Flow event.
     *
     * @param  array  $data  The clean data array from the event
     * @param  int  $blockHeight  The block where it happened
     */
    public function handle(array $data, int $blockHeight): void;
}
