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
}
