function convexHull2VTK( points::Array{T,2}, 
                         vertices::Array{Int64,1}, 
                         simplices::Array{Array{Int64,1},1}; 
                         fn="tmp.vtk", path=pwd(), mode="w" ) where {T<:Real}

    data_type = get( Julia2VTK, T, "" );
    ( data_type ==  "" ) && ( error("Unrecognized data type") );

    num_points = size(points,1);
	num_faces  = length(simplices)

    save_path = parseFilename( fn, path, ".vtk" );

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET POLYDATA" )
        println( io, "POINTS $(num_points) $(data_type)")
        for v in 1:size(points,1)
            println( io, string( "$(points[v,1]) $(points[v,2]) $(points[v,3])" ) )
        end

		println( io, "POLYGONS $(num_faces) $(4*num_faces)" )
		for s in simplices
			p1, p2, p3 = s[1], s[2], s[3]; 
			println( io, "3 $(p1-1) $(p2-1) $(p3-1)" )
		end

    close(io)

    println( "convexHull vtk saved.")
end

function convexHull2VTK( points::Array{NTuple{3,T},1}, 
                         simplices::Array{NTuple{3,T2},1},
						 normals::Array{NTuple{3,Float32},1};
                         fn="tmp.vtk", path=pwd(), mode="w" ) where {T<:Real,T2<:Integer}


    data_type = get( Julia2VTK, Float32, "" );
    ( data_type ==  "" ) && ( error("Unrecognized data type") );

    num_points = size(points,1);
	num_faces  = length(simplices)

    save_path = parseFilename( fn, path, ".vtk" );

	face_centers = Array{NTuple{3,Float32},1}(undef,length(simplices)); 
	for fidx in 1:length(simplices)
		face   = simplices[fidx]; 
		center = zeros( Float32, 3 );
		for idx in 1:length(face)
			center .+= points[ face[idx] ]; 
		end 
		face_centers[fidx] = Tuple( center ./ 3 )
	end

    io = open( save_path, mode )
        println( io, "# vtk DataFile Version 2.0" )
        println( io, "PIV3D Trajectories" )
        println( io, "ASCII" )
        println( io, "DATASET UNSTRUCTURED_GRID" )
        println( io, "POINTS $(num_points+length(simplices)) $(data_type)")
        for v in 1:size(points,1)
            println( io, string( "$(points[v][1]) $(points[v][2]) $(points[v][3])" ) )
        end
        for v in 1:size(face_centers,1)
            println( io, string( "$(face_centers[v][1]) $(face_centers[v][2]) $(face_centers[v][3])" ) )
        end

		println( io, "CELLS $(num_faces) $((num_faces)*4)" )
		for s in simplices
			p1, p2, p3 = s[1], s[2], s[3]; 
			println( io, "3 $(p1-1) $(p2-1) $(p3-1)" )
		end			

		println( io, "CELL_TYPES $(num_faces)" )
		for s in simplices
			println( io, "5" )
		end

		println( io, "POINT_DATA $(num_points+length(simplices))" ); 
		println( io, "VECTORS normals float" );
        for v in points
            println( io, string( "0 0 0 " ) )
        end
        for v in normals
            println( io, string( "$(v[1]) $(v[2]) $(v[3])" ) )
        end
		

    close(io)

    println( "convexHull 2 vtk saved.")
end
