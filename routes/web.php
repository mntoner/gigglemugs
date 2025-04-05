<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Models\Locations; // <-- Import Locations model

use App\Http\Controllers\Auth\TwoFactorAuthenticationController;
use App\Http\Controllers\Auth\TwoFactorChallengeController;
use App\Http\Controllers\SupplierController;
use App\Http\Controllers\BuyItemController;
use App\Http\Controllers\PurchaseOrderController;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);

    // redirect to login if not authenticated
    //return redirect()->route('login');
});

// Location Page Route (Publicly Accessible)
Route::get('/location/{location}/{location_name}', function (Locations $location, $location_name) {
    // The {location} parameter uses route model binding to fetch the Locations model instance.
    // The {location_name} is present for SEO/user-friendly URLs but not strictly needed for fetching.
    // We could add validation to ensure location_name matches the fetched location if desired.
    return Inertia::render('Location', [
        'location' => $location,
    ]);
})->name('location.show');

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');


Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware(['auth'])->group(function () {
    Route::get('/two-factor', [TwoFactorAuthenticationController::class, 'show'])->name('2fa.show');
    Route::post('/two-factor/enable', [TwoFactorAuthenticationController::class, 'enable'])->name('2fa.enable');
    Route::post('/two-factor/disable', [TwoFactorAuthenticationController::class, 'disable'])->name('2fa.disable');
});

Route::middleware('guest')->group(function () {
    Route::get('/2fa/challenge', [TwoFactorChallengeController::class, 'show'])
        ->name('2fa.challenge');

    Route::post('/2fa/challenge', [TwoFactorChallengeController::class, 'store'])
        ->name('2fa.challenge.store');
});

require __DIR__.'/auth.php';
