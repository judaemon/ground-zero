<?php

namespace App\Console\Commands;

use App\Jobs\TestJob;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class TestCommand extends Command
{
  protected $signature = 'app:test-command';

  protected $description = 'Test Command Description';

  public function handle()
{
    $key = random_int(1000, 9999);

    Log::info("TestCommand started", ['key' => $key]);
    
    dispatch(new TestJob($key));
    Log::info("TestJob dispatched", ['key' => $key]);
}
}
