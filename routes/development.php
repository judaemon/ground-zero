<?php

use App\Http\Middleware\LocalEnvironment;
use Illuminate\Support\Facades\Route;

Route::middleware([LocalEnvironment::class, 'auth'])->group(function () {
    Route::get('test', function () {
        return 'Test route';
    });
});
