<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Locations;

class HomeController extends Controller
{
    public function show(Locations $location, $location_name){

        return Inertia::render('Location', [
            'location' => $location,
        ]);
    }

    /**
     * Fetch locations by city for the navigation panel.
     *
     * @param  string  $city
     * @return \Illuminate\Http\JsonResponse
     */
    public function getLocationsByCity(string $city)
    {
        // Decode the city name passed in the URL
        $decodedCity = urldecode($city);

        // Query locations matching the city, selecting only necessary fields
        $locations = Locations::where('city', $decodedCity)
                            ->select('id', 'name') // Select only id and name
                            ->orderBy('name') // Optional: order by name
                            ->get();

        return response()->json($locations);
    }
}

