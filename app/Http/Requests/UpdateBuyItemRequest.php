<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBuyItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:application.category,id',
            'subcategory_id' => 'nullable|exists:application.subcategory,id',
            'preferred_buy_item_supplier_id' => 'nullable|exists:application.buy_item_supplier,id',
            'sell_item_json' => 'nullable|array',
            'ingredient_json' => 'nullable|array',
            'nutrition_json' => 'nullable|array',
            'intolerances_json' => 'nullable|array',
            'unavailable' => 'boolean',
            'sell_item_required' => 'integer|in:0,1,2'
        ];
    }
}