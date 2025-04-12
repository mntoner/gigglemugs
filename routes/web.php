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
        'canLogin' => false,
        'canRegister' => false,
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);

    // redirect to login if not authenticated
    //return redirect()->route('login');
});

// Location Page Route (Publicly Accessible)
Route::get('/location/{location}/{location_name}', [App\Http\Controllers\HomeController::class, 'show'])
    ->name('location.show');

// Route to fetch locations for the navigation panel
Route::get('/locations/city/{city}', [App\Http\Controllers\HomeController::class, 'getLocationsByCity'])
    ->name('locations.byCity');

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
