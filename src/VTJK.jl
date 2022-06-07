module VTJK

Julia2VTK = Dict( 
    Bool    => "unsigned_char",
	UInt8   => "unsigned_char" , Int8  =>  "signed_char",
	UInt16  => "unsigned_short", Int16 =>  "short",
	UInt32  => "unsigned_int"  , Int32 =>  "int",
	UInt64  => "unsigned_long" , Int64 =>  "long",
	Float32 => "float",          Float64 => "double"
)

VTK2Julia = Dict( "unsigned_char"  =>  UInt8, "char"  =>  Int8,
                  "unsigned_short" => UInt16, "short" => Int16,
                  "unsigned_int"   => UInt32, "int"   => Int32,
                  "unsigned_long"  => UInt64, "long"  => Int64,
                  "float" => Float32, "double" => Float64     )

function parseFilename( filename, path, format )

    if path == "" 
        return path*filename
    end

	( path[end] !== '/' || path[end] !== "\\" ) && ( path = path*"/" ); 
    ( length(filename) < 4 ) && ( filename = filename*format ); 
    !( occursin( '/', filename ) ) && ( filename = path*filename );
    !( occursin( '.', filename[end-4:end] ) ) && ( filename = filename*format )

    return filename;
end

include("points.jl")
include("convexHull.jl")
include("volumes.jl")
include("vectorFields.jl")

end
