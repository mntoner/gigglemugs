<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Locations extends Model
{
    protected $table = 'locations';

    protected $fillable = [
        'type',
        'name',
        'address',
        'city',
        'county',
        'country',
        'postal_code',
        'phone',
        'email',
        'website',
        'latitude',
        'longitude',
        'details',
        'is_active'
    ];

    protected $casts = [
        'details' => 'array',
    ];
}
