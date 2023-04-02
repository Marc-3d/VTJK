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
                          fn="tmp.vkt", path=pwd(), mode="w",
                          spacing=(1,1,1), origin=(0,0,0),						  
						  silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path  = parseFilename( fn, path, ".vtk" );
	h , w , d  = size( U ); 
	s1, s2, s3 = spacing; 
	o1, o2, o3 = origin;

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w $d"  );
		println( io, "ORIGIN $(o1) $(o2) $(o3)"  );
		println( io, "SPACING $(s1) $(s2) $(s3)"  );
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

function VTKVectorfieldSize( file )
	io = Base.open( file, "r" )
	l1 = Base.readline( io ); # 1st line: # vtk DataFile Version 2.0
	l2 = Base.readline( io ); # 2nd line: VTJK volume
	l3 = Base.readline( io ); # 3rd line: ASCII
	l4 = Base.readline( io ); # 4rt line: DATASET STRUCTURED_POINTS
	l5 = Base.readline( io ); # 5th line: Dimensions $h, $w, $d
	h, w, d = parse.( Int64, split(l5," ")[2:4] )
	Base.close(io); 
	return h, w, d
end


function VTK2vectorfield(; fn="tmp.vkt", path=pwd(), silent=true )
	
	fn = parseFilename( fn, path, ".vtk" ); 
	isfile(fn) || error("$fn can not be found")

	lines = readlines(fn);
	( lines[2][1:4] !== "VTJK" ) && (error("The vtk vector field was not stored with VTJK, and cannot open it safely." ))

	h, w, d = VTKVectorfieldSize( fn ); 

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
