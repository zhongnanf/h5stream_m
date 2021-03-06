# h5stream_m
A Matlab class for writing image data as stream into chunks of hdf5 files

## Matlab help information:
### Create the object

```
h5s = h5stream()
h5s = h5stream(chunk_size, image_size, n_channels, data_type)
```
e.g. chunk_size = 100, image_size = [128 128], n_channels = 3, data_type = 'single'

### Initialize the stream
```
h5s.init_stream(save_prefix,dataset_name)
```
e.g. save_prefix = '/path/to/hdf5file', dataset_name = '/images'

### Export images to the stream
```
h5s.export(image)
```
e.g. image = matrix of size [128 128 3]

* Repeated calling the "export" function to export the image stream
```
for cnt1 = 1:N
    h5s.export(rand(128,128,3));
end
```
### Close the stream
```
h5s.close_stream()
```

Author: Zhongnan Fang, 2016-03-10
