<?php

use App\Http\Middleware\LocalEnvironment;
use Illuminate\Support\Facades\Route;
use Spatie\Activitylog\Models\Activity;

Route::middleware([LocalEnvironment::class])->prefix('test')->group(function () {
    Route::get('/', function () {
        $activityLogs = Activity::all();
        return response()->json($activityLogs);
    });

    Route::get('/users', function () {
        activity()
            ->useLog('test')
            ->log('Viewed users');

            $users = \App\Models\User::all();

        return response()->json($users);
    });
});
