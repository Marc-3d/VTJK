function vectorfield2VTK( U::Array{T,2}, V::Array{T,2}; 
                          fn="tmp.vkt", path=pwd(), mode="w", silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w   = size( U ); 

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w 1"  );
		println( io, "ORIGIN 0 0 0"  );
		println( io, "SPACING 1 1 1"  );
        println( io, "POINT_DATA $(length(U))"  )
        println( io, "VECTORS directions $data_type"  )
		for x in 1:w
			for y in 1:h
        		println( io, string( U[y,x], " ", V[y,x], " 0" ) )
			end
		end

    close(io)

    silent || println( "VF saved.")
end

function vectorfield2VTK( U::Array{T,3}, V::Array{T,3}, W::Array{T,3}; 
                          fn="tmp.vkt", path=pwd(), mode="w", silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( U ); 

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w $d"  );
		println( io, "ORIGIN 0 0 0"  );
		println( io, "SPACING 1 1 1"  );
        println( io, "POINT_DATA $(length(U))"  )
        println( io, "VECTORS directions $data_type"  )

		for z in 1:d
				for x in 1:w
					for y in 1:h
            		println( io, string( U[y,x,z], " ", V[y,x,z], " ", W[y,x,z] ) )
				end
			end
        end
    close(io)

    silent || println( "VTK volume saved.")
end


function VTK2vectorfield(; fn="tmp.vkt", path=pwd(), silent=true )
	
	fn = parseFilename( fn, path, ".vtk" )
	isfile(fn) || error("$fn can not be found")

	lines = readlines(fn);
	( lines[2][1:4] !== "VTJK" ) && (error("The vtk vector field was not stored with VTJK, and cannot open it" ))

	h, w, d = parse.( Int64, split(lines[5]," ")[2:4] )

	_, _, dtype = split( lines[9], " " );
	data_type = get( VTK2Julia, dtype, Bool );

	U = Array{data_type, 3}(undef, h, w, d);
	V = Array{data_type, 3}(undef, h, w, d);
	W = Array{data_type, 3}(undef, h, w, d);

	vector_start, offset = 10, 0;

	for z in 1:d, x in 1:w, y in 1:h
		_u, _v, _w = parse.( data_type, split( lines[vector_start+offset] ) )
		U[y, x, z] = _u
		V[y, x, z] = _v
		W[y, x, z] = _w
		offset += 1;
	end

	return U, V, W
end
