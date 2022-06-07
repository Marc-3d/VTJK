function points2VTK( inp::Array{T,2}; fn="tmp.vtk", path=pwd(), mode="w" ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type ==  "" ) && ( error("Unrecognized data type") );

    num_points = size( inp, 1 );

    save_path = parseFilename( fn, path, ".vtk" );

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET POLYDATA" )
        println( io, "POINTS $(num_points) $(data_type)")
        for p in 1:num_points
            println( io, string( "$(inp[p,1]) $(inp[p,2]) $(inp[p,3])" ) )
        end
    close(io)

    println( "points vtk saved.")
end

function points2VTK( inp; fn="tmp.vtk", path=pwd(), mode="w" )

    data_type = get( Julia2VTK, eltype(inp[1]), "" );
    ( data_type ==  "" ) && ( error("Unrecognized data type") );

    num_points = length( inp );

    save_path = parseFilename( fn, path, ".vtk" );

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET POLYDATA" )
        println( io, "POINTS $(num_points) $(data_type)")
        for p in 1:num_points
            println( io, string( "$(inp[p][1]) $(inp[p][2]) $(inp[p][3])" ) )
        end
    close(io)

    println( "points vtk saved.")
end

function pointsValue2VTK( inp, values; fn="tmp.vtk", path=pwd(), mode="w" )

    data_type1 = get( Julia2VTK, eltype(inp[1]), "" );
    data_type2 = get( Julia2VTK, typeof(values[1]), "" );
    ( data_type1 ==  "" ) && ( error("Unrecognized data type") );
    ( data_type2 ==  "" ) && ( error("Unrecognized data type") );

    num_points = size( inp, 1 );
    save_path  = parseFilename( fn, path, ".vtk" );

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET POLYDATA" )
        println( io, "POINTS $(num_points) $(data_type1)")
        for p in 1:num_points
            println( io, string( "$(inp[p][1]) $(inp[p][2]) $(inp[p][3])" ) )
        end        
		println( io, "POINT_DATA $(length(values))"  )
        println( io, "SCALARS value $(data_type2)"  )
        println( io, "LOOKUP_TABLE default" )

		for val in values
    		println( io, string( val ) )
        end
    close(io)

    println( "points values vtk saved.")
end

function pointsNorm2VTK( inp, norms; fn="tmp.vtk", path=pwd(), mode="w" )

    data_type1 = get( Julia2VTK, eltype(inp[1]), "" );
    data_type2 = get( Julia2VTK, eltype(norms[1]), "" );
    ( data_type1 ==  "" ) && ( error("Unrecognized data type") );
    ( data_type2 ==  "" ) && ( error("Unrecognized data type") );

    num_points = size( inp, 1 );
    save_path  = parseFilename( fn, path, ".vtk" );

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET POLYDATA" )
        println( io, "POINTS $(num_points) $(data_type1)")
        for p in 1:num_points
            println( io, string( "$(inp[p][1]) $(inp[p][2]) $(inp[p][3])" ) )
        end        
		println( io, "POINT_DATA $(length(norms))"  )
        println( io, "VECTORS directions $(data_type2)"  )

		for n in norms
    		println( io, string( n[1], " ", n[2], " ", n[3] ) )
        end
    close(io)

    println( "points norms vtk saved.")
end



