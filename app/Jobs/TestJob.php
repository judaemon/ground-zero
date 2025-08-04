<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class TestJob implements ShouldQueue
{
  use Queueable;

  private $key;

  public function __construct($key)
  {
    $this->key = $key;
  }

  public function handle(): void
  {
    Log::info('TestJob executing', ['key' => $this->key]);
  }
}
