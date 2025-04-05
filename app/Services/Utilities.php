<?php

namespace App\Services;

use App\Models\Locations;

class Utilities
{

    public static function addImage($location_id, $image_path)
    {
        // check if location.details json field contains the key 'featured_image'
        $location = Locations::find($location_id);
        if ($location) {
            $details = $location->details;
            if (isset($details['featured_image'])) {
                return $details['featured_image'];
            } else {
                $details['featured_image'] = $image_path;
                $location->details = $details;
                $location->save();
                return $image_path;
            }
        } else {
            return null;

        }

    }
    

}