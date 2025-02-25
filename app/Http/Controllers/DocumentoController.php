<?php
namespace App\Http\Controllers;

use App\Models\Documento;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DocumentoController extends Controller
{
    public function index(): JsonResponse
    {
        try {
            $documentos = Documento::all();
            return response()->json([
                'status' => 'success',
                'data' => $documentos
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $request->validate([
            'denominacion' => 'required|string',
            'cantidad' => 'required|integer'
        ]);

        $documento = Documento::create($request->all());
        return response()->json($documento, 201);
    }

    public function show(Documento $documento)
    {
        return response()->json($documento);
    }

    public function update(Request $request, Documento $documento)
    {
        $request->validate([
            'denominacion' => 'required|string',
            'cantidad' => 'required|integer'
        ]);

        $documento->update($request->all());
        return response()->json($documento);
    }

    public function destroy(Documento $documento)
    {
        $documento->delete();
        return response()->json(null, 204);
    }
}

