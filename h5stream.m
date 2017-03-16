classdef h5stream < handle
    
    % H5STREAM
    % Object that writes stream of images into chunks of hdf5 files
    % [USAGE]
    % 1. Create the object
    % h5s = h5stream()
    % h5s = h5stream(chunk_size, image_size, n_channels, data_type)
    % e.g. chunk_size = 100, image_size = [128 128], n_channels = 3,
    %      data_type = 'single'
    %
    % 2. Initialize the stream
    % h5s.init_stream(save_prefix,dataset_name)
    % e.g. save_prefix = '/path/to/hdf5file'
    % dataset_name = '/images'
    %
    % 3. Export images to the stream
    % h5s.export(image)
    % e.g. image = matrix of size [128 128 3]
    % Repeated calling the "export" function to export the image stream
    % e.g.
    % for cnt1 = 1:N
    %     h5s.export(rand(128,128,3));
    % end
    % 4. Close the stream
    % h5s.close_stream()
    %
    % Author: Zhongnan Fang, 2016-03-10
    
    properties
        chunk_size
        image_size
        n_channels
        data_type
        save_prefix
        streaming
        h5_text_file
        counter
        chunk_counter
        images
        dataset_name
    end
    
    methods
        
        function obj = h5stream(chunk_size, image_size, n_channels, data_type)
            if nargin == 0
                chunk_size = 100;
                image_size = [128,128];
                n_channels = 3;
                data_type = 'single';
            end
            
            obj.chunk_size = chunk_size;
            obj.image_size = image_size;
            obj.n_channels = n_channels;
            obj.chunk_counter = 1;
            obj.counter = 1;
            obj.streaming = 0;
            obj.data_type = data_type;
        end
        
        function obj = init_stream(obj,save_prefix,dataset_name)
            
            if obj.streaming
                error('[H5STREAM] h5stream has already been initialized, close it before reuse');
            end
            
            % initialize memory space and file io handler
            obj.images = zeros([reshape(obj.image_size,1,[]),obj.n_channels,obj.chunk_size]);
            eval(sprintf('obj.images = %s(obj.images);',obj.data_type));
            obj.counter = 1;
            obj.chunk_counter = 1;
            obj.save_prefix = save_prefix;
            obj.dataset_name = dataset_name;
            obj.h5_text_file = fopen(sprintf('%s.txt',obj.save_prefix),'w');
            obj.streaming = 1;
        end
        
        function obj = export(obj,image)
            
            if obj.streaming
            
                leaddims = repmat({':'},1,ndims(obj.images)-1);
                obj.images(leaddims{:},obj.counter) = image;
                obj.counter = obj.counter + 1;

                if obj.counter > obj.chunk_size
                    h5name = sprintf('%s_%d.h5',obj.save_prefix,obj.chunk_counter);
                    h5create(h5name,obj.dataset_name,size(obj.images),'DataType',obj.data_type);
                    h5write(h5name,obj.dataset_name,obj.images);
                    fprintf(obj.h5_text_file,'%s\n',h5name);
                    obj.counter = 1;
                    obj.chunk_counter = obj.chunk_counter + 1;
                end
            
            else
                error('[H5STREAM] Initialize the h5stream before export');
            end
            
        end
        
        function obj = close_stream(obj)
            
            if ~obj.streaming
                error('[H5STREAM] Initialize the h5stream before close');
            end
            
            % if there is still images hasn't exported inside the memory
            if obj.counter > 1
                leaddims = repmat({':'},1,ndims(obj.images)-1);
                obj.images = obj.images(leaddims{:},1:obj.counter-1);
                h5name = sprintf('%s_%d.h5',obj.save_prefix,obj.chunk_counter);
                h5create(h5name,obj.dataset_name,size(obj.images),'Datatype',obj.data_type);
                h5write(h5name,obj.dataset_name,obj.images);
                fprintf(obj.h5_text_file,'%s\n',h5name);
            end
            fclose(obj.h5_text_file);
            obj.streaming = 0;
            
        end
        
    end
end
