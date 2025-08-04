<?php

use App\Console\Commands\TestCommand;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
  $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');


// Test Task Scheduler
// Schedule::call(fn () => Log::info("Hello world!"))->everySecond();

// Test Queue Job
// Schedule::command('app:test-command')->everySecond();
// Schedule::command(TestCommand::class)->everyThirtyMinutes();
