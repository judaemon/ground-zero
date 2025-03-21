<?php

namespace App\Http\Controllers\Test;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Spatie\Activitylog\Models\Activity;

class TestController extends Controller
{
    public function index()
    {
        activity()
            ->useLog('test')
            ->causedBy(Auth::user())
            ->event('viewed')
            ->log('viewed test logs');

        $activityLogs = Activity::query()
            ->where('log_name', 'test')
            ->get();

        return response()->json($activityLogs);
    }
}
