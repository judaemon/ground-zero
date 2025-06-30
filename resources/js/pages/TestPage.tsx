import { type SharedData } from '@/types';
import { Head, Link, usePage } from '@inertiajs/react';

export default function TestPage() {
    const { auth } = usePage<SharedData>().props;

    return (
        <>
            <Head title="Test Page">
                <link rel="preconnect" href="https://fonts.bunny.net" />
                <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600" rel="stylesheet" />
            </Head>
            <div className="flex min-h-screen flex-col items-center bg-[#FDFDFC] p-6 text-[#1b1b18] lg:justify-center lg:p-8 dark:bg-[#0a0a0a]">
              <h1 className="text-amber-200">Test Page</h1>
            </div>
        </>
    );
}
