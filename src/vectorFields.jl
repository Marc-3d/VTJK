# ASCII

function vectorfield2VTK( U::Array{T,2}, V::Array{T,2}; 
                          fn="tmp.vtk", path=pwd(), 
						  spacing=(1,1), origin=(0,0), 
						  mode="w", silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	 h,  w = size( U );
	s1, s2 = spacing
	o1, o2 = origin 

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w 1"  );
		println( io, "ORIGIN $(o1) $(o2) $(o3)"  );
		println( io, "SPACING $(s1) $(s2) $(s3)"  );
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
                          fn="tmp.vtk", path=pwd(), mode="w",
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


function VTK2vectorfield(; fn="tmp.vtk", path=pwd(), silent=true )
	
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

### BINARY

function vectorfield2VTK_bin( U::Array{T,2}, V::Array{T,2}; 
                              fn="tmp.vtk", path=pwd(), 
						      spacing=(1,1), origin=(0,0), 
						      mode="w", silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	 h,  w = size( U );
	s1, s2 = spacing
	o1, o2 = origin 

    io = open( save_path, mode )
	header = """# vtk DataFile Version 2.0
	VTJK vector field
	BINARY
	DATASET STRUCTURED_POINTS
	DIMENSIONS $h $w 1
	ORIGIN $(o1) $(o2) 0
	SPACING $(s1) $(s2) 1
	POINT_DATA $(length(U))
	VECTORS directions $data_type"""


	io_buff = IOBuffer( maxsize=length(U)*sizeof(T)*3 + length(header) + 1 ); 

	println( io_buff, header ); 
	for idx in 1:length(U)
		write( io_buff, Base.hton(U[idx]) ); 
		write( io_buff, Base.hton(V[idx]) ); 
		write( io_buff, Base.hton( T(0) ) ); 
	end

	write( io_buff, "\n" ); 

	open( save_path, mode ) do f
		write( f, take!( io_buff ) )
	end

	!silent && println( "VF saved.")
end

function VTK2vectorfield_bin(; fn="tmp.vtk", path=pwd()*"\\", silent=true )
	
	fn = parseFilename( fn, path, ".vtk" ); 
	isfile(fn) || error("$fn can not be found")

	# IOStream
	f = open( fn )

	# Parsing the first 9 lines, which correspond to the header and the attributes title
	header = [ Vector{UInt8}(undef,0) for n in 1:9 ]
	line   = 1 
	while true
		b = read( f, 1 )
		if ( b[1] == UInt8(10) )
			line += 1
		else
			push!( header[line], b[1] )
		end
		if line > 9
			break
		end
	end
	lines = String.( header ); 
	( lines[2][1:4] !== "VTJK" ) && (error("The vtk vector field was not stored with VTJK, and cannot open it safely." ))

	# Extracting dimensions of the vector field from the header
	h, w, d     = parse.( Int64, split( String(lines[5]), " " )[end-2:end] ); 
	_, _, dtype = split( lines[9], " " );
	data_type   = VTJK.get( VTJK.VTK2Julia, dtype, Bool );

	U = Array{data_type, 3}(undef, h, w, d);
	V = Array{data_type, 3}(undef, h, w, d);
	W = Array{data_type, 3}(undef, h, w, d);

	# Reading the remaining of the IOStream, which corresponds to the elements of the vectorfield
	for z in 1:d, x in 1:w, y in 1:h
		u = data_type(ntoh(read( f, data_type )))
		v = data_type(ntoh(read( f, data_type )))
		w = data_type(ntoh(read( f, data_type )))
		U[y, x, z] = u
		V[y, x, z] = v
		W[y, x, z] = w
	end

	return U, V, W
end
