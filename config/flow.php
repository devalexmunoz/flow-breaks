<?php

return [

    /**
     * Map of Contract Events to their Listener Classes.
     * The key format must be: 'ContractName.EventName'
     * * The 'ContractName' must match a key in your services.flow.contracts config.
     */
    'events' => [
        'Breaks.BreakCreated' => \App\Flow\Handlers\BreakCreatedHandler::class,
    ],

];
