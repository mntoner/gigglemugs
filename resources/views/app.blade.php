<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title inertia>{{ config('app.name', 'Laravel') }} GGG</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @routes
        @vite(['resources/js/app.js', "resources/js/Pages/{$page['component']}.vue"])
        @inertiaHead

        <!-- Google Maps API -->
        {{-- Removed callback=initMap as Vue component handles initialization. Added async. --}}
        <script src="https://maps.googleapis.com/maps/api/js?key={{ env('VITE_GOOGLE_MAPS_API_KEY') }}&libraries=marker" async defer></script>
        {{-- Ensure VITE_GOOGLE_MAPS_API_KEY is set in your .env file and Maps JavaScript API is enabled in Google Cloud Console --}}
    </head>
    <body class="font-sans antialiased">
        @inertia
    </body>
</html>
