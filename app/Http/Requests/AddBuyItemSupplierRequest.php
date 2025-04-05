<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AddBuyItemSupplierRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'supplier_id' => 'required|exists:application.supplier,id',
            'supplier_product_code' => 'required|string|max:255',
            'default_buy_size_id' => 'nullable|exists:application.buy_size,id',
            'default_count_size_id' => 'nullable|exists:application.count_size,id',
            'latest_buy_price' => 'nullable|numeric|min:0',
            'set_as_preferred' => 'boolean'
        ];
    }
}