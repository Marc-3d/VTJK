convert( typ::Type{<:Integer      }, num::AbstractFloat ) = round(typ,num)
convert( typ::Type{<:AbstractFloat}, num::AbstractFloat ) = typ(num)
convert( typ::Type{<:AbstractFloat}, num::Integer       ) = typ(num)
convert( typ::Type{<:Integer      }, num::Integer       ) = typ(num)

function volume2VTK( volume::Array{T,3};
                     fn="tmp.vkt", path=pwd(), 
					 spacing=(1,1,1), origin=(0,0,0), 
					 mode="w", typ=eltype(volume), silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, typ, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );
	s1,s2,s3  = spacing
	o1,o2,o3  = origin

	# using a buffer to try to get better performance while writting big matrices
	header = """# vtk DataFile Version 2.0
	VTJK volume
	BINARY
	DATASET STRUCTURED_POINTS
	DIMENSIONS $h $w $d 
	ORIGIN $(o1) $(o2) $(o3)
	SPACING $(s1) $(s2) $(s3)
	POINT_DATA $(length(volume))
	SCALARS intensities $data_type
	LOOKUP_TABLE default"""

	io_buff = IOBuffer( maxsize=length(volume)*T.size + length(header) + 1 ); 

	println( io_buff, header ); 
	for e in volume
		write( io_buff, Base.hton(e) ); 
	end

	write( io_buff, "\n" ); 

	open( save_path, mode ) do f
		write( f, take!( io_buff ) )
	end

    !silent && println( "VTK volume saved.")
end

function volume2VTK_swap( volume::Array{T,3};
	                      fn="tmp.vkt", path=pwd(), mode="w", typ=eltype(volume), silent=true ) where {T<:Real}

	data_type = get( Julia2VTK, typ, "" );
	( data_type == "" ) && ( error("Unrecognized data type") );

	save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );

	io = open( save_path, mode )
	println( io, "# vtk DataFile Version 2.0"  );
	println( io, "VTJK volume"  );
	println( io, "ASCII"  );
	println( io, "DATASET STRUCTURED_POINTS"  );
	println( io, "DIMENSIONS $w $h $d"  );
	println( io, "ORIGIN 0 0 0"  );
	println( io, "SPACING 1 1 1"  );
	println( io, "POINT_DATA $(length(volume))"  );
	println( io, "SCALARS intensities $data_type"  );
	println( io, "LOOKUP_TABLE default" );
	@inbounds for z in 1:d, y in 1:h,  x in 1:w
		println( io, volume[y,x,z] )
	end
	close(io)

	!silent && println( "VTK volume saved.")
end


function volume2VTK( volume::Array{T,3}, off;
                     fn="tmp.vkt", path=pwd(), mode="w", typ=eltype(volume), silent=true ) where {T<:Real}

    data_type = get( Julia2VTK, typ, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w $d"  );
		println( io, "ORIGIN $(off[1]) $(off[2]) $(off[3])"  );
		println( io, "SPACING 1 1 1"  );
		println( io, "POINT_DATA $(length(volume))"  );
		println( io, "SCALARS intensities $data_type"  );
		println( io, "LOOKUP_TABLE default" );
		@inbounds for z in 1:d, x in 1:w, y in 1:h
		    		println( io, volume[y,x,z] )
		end
    close(io)

    !silent && println( "VTK volume saved.")
end

function volume2VTK_arrow( volume::Array{T,3}, off, arrow;
                           fn="tmp.vkt", path=pwd(), mode="w", typ=eltype(volume) ) where {T<:Real}

    data_type = get( Julia2VTK, typ, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w $d"  );
		println( io, "ORIGIN $(off[1]) $(off[2]) $(off[3])"  );
		println( io, "SPACING 1 1 1"  );
		println( io, "POINT_DATA $(length(volume))"  );
		println( io, "SCALARS intensities $data_type"  );
		println( io, "LOOKUP_TABLE default" );
		@inbounds for z in 1:d, x in 1:w, y in 1:h
    		println( io, volume[y,x,z] )
		end
		println( io, "VECTORS piv float" )
		mid = div.( size(volume), 2 );
		@inbounds for z in 1:d, x in 1:w, y in 1:h
			if (y,x,z) == mid
    			println( io, arrow[1], "  ", arrow[2], "  ", arrow[3] )
			else
				println( io, 0.0, "  ", 0.0, "  ", 0.0 )
			end
		end
    close(io)

    println( "VTK volume saved.")
end

#=
function volume2VTK( volume::Array{Bool,3};
                     fn="tmp.vkt", path=pwd(), mode="w", typ=UInt16 ) where {T<:Real}

    data_type = get( Julia2VTK, typ, "" );
    ( data_type == "" ) && ( error("Unrecognized data type") );

    save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );

    io = open( save_path, mode )
		println( io, "# vtk DataFile Version 2.0"  );
		println( io, "VTJK volume"  );
		println( io, "ASCII"  );
		println( io, "DATASET STRUCTURED_POINTS"  );
		println( io, "DIMENSIONS $h $w $d"  );
		println( io, "ORIGIN 0 0 0"  );
		println( io, "SPACING 1 1 1"  );
		println( io, "POINT_DATA $(length(volume))"  );
		println( io, "SCALARS intensities $data_type"  );
		println( io, "LOOKUP_TABLE default" );
		@inbounds for z in 1:d
			for x in 1:w
				for y in 1:h
		    		println( io, UInt8(volume[y,x,z]) )
				end
			end
		end
    close(io)

    println( "VTK volume saved.")
end
=#

function volume2VTK_swap( volume::Array{Bool,3};
		fn="tmp.vkt", path=pwd(), mode="w", typ=UInt16 ) where {T<:Real}

	data_type = get( Julia2VTK, typ, "" );
	( data_type == "" ) && ( error("Unrecognized data type") );

	save_path = parseFilename( fn, path, ".vtk" );
	h, w, d   = size( volume );

	io = open( save_path, mode )
	println( io, "# vtk DataFile Version 2.0"  );
	println( io, "VTJK volume"  );
	println( io, "ASCII"  );
	println( io, "DATASET STRUCTURED_POINTS"  );
	println( io, "DIMENSIONS $w $h $d"  );
	println( io, "ORIGIN 0 0 0"  );
	println( io, "SPACING 1 1 1"  );
	println( io, "POINT_DATA $(length(volume))"  );
	println( io, "SCALARS intensities $data_type"  );
	println( io, "LOOKUP_TABLE default" );
	@inbounds for z in 1:d, y in 1:h, x in 1:w
		println( io, UInt8(volume[y,x,z]) )
	end
	close(io)

	println( "VTK volume saved.")
end
