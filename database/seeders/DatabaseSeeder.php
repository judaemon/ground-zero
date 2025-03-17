<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

// To seed the database, we need to run the following command:
// php artisan db:seed

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call(UserSeeder::class);
    }
}
