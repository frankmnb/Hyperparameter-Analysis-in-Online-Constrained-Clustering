# Hyperparameter-Analysis-in-Online-Constrained-Clustering

This contains MATLAB code for analysing different combinations of parameters in online constrained clustering. These are the proportion of constraints, initial number of clusters, and the batch window size.

## Usage
`MainIterator.m` is the main file from which all the functions are called. Edit the variables to incorporate your data and your desired hyperparameters.

### Data
The data must be in .csv format and stored using the following formatting:

Bounding Box (BB) Frame Data:

|BB top-left x|BB top-left y|BB width|BB height|frame number|frame width|frame height|object label|frame image name|
|---:|---:|---:|---:|---:|---:|---:|---:|:---|
|354|	259|	276|	247|	1|	952|	540|	3|	Florence_frame_00001.jpg|
|342|	408|	140|	132|	1|	952|	540|	5|	JP_frame_00001.jpg|
|218|	173|	371|	136|	1|	952|	540|	6|	Jack_frame_00001.jpg|
|352|	72|	367|	240|	1|	952|	540|	8|	Selwyn_frame_00001.jpg|
|362|	276|	260|	228|	2|	952|	540|	3|	Florence_frame_00002.jpg|
|341|	415|	129|	123|	2|	952|	540|	5|	JP_frame_00002.jpg|

Feature Data - see link below for examples :point_down:

Constraints Data:

|Object A|Object B|ML/CL|
|---:|---:|:---:|
|1|	5|	0.84631511|
|2|	6|	0.884163644|
|3|	7|	0.754439876|
|8|	9|	-1|
|8|	10|	-1|

where the decimal is the IoU between the two BB's (Must-link), and '-1' means both objects are in the same frame (Cannot-link).

Examples of the datasets as used in the code can be found here :point_right: https://zenodo.org/record/7322821 .

### Methods
- `kul.m` - Kulshreshtha method [^2]
- `online_cop_kmeans.m` - Online COP-Kmeans
- `osl.m` - Online SIngle Linkage
- `bla.m` - BaseLine A "same"
- `blb.m` - BaseLine B "different"
- `blc.m` - BaseLine C "random

### Metrics
- `normalised_mutual_information.m` - Normalised Mutual Information (NMI) [^3]
- `adjusted_rand_index.m` - Adjusted Rand Index (ARI) [^3]
- `classification_accuracy.m` - Classification Accuracy "Count"
- `classification_accuracy_old.m` - Classification Accuracy "Hungarian"

## References
[^2]: Kulshreshtha, Prakhar, and Tanaya Guha. "An online algorithm for constrained face clustering in videos." 2018 25th IEEE International Conference on Image Processing (ICIP). IEEE, 2018.
[^3]: Vinh, Nguyen Xuan, Julien Epps, and James Bailey. "Information theoretic measures for clusterings comparison: is a correction for chance necessary?." Proceedings of the 26th annual international conference on machine learning. 2009.
