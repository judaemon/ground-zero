<?php

use App\Http\Controllers\Test\TestController;
use App\Http\Middleware\LocalEnvironment;
use Illuminate\Support\Facades\Route;

Route::middleware([LocalEnvironment::class])->group(function () {
    Route::prefix('test')->controller(TestController::class)->group(function () {
        Route::get('/', 'index');
    });
});
