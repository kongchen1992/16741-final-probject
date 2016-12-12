readOnly_root = '/Users/kongchen/dataset';
root = '/Users/kongchen/dataset';
ShapeNet_dir = fullfile(readOnly_root, 'ShapeNetCore.v1');
PASCAL3D_dir = fullfile(readOnly_root, 'PASCAL3D+_release1.1');
VOC_dir = fullfile(readOnly_root, 'VOCdevkit', 'VOC2012');

Anchor_dir = fullfile(root, 'ShapeNetAnchors');
Graph_dir = fullfile(root, 'ShapeNetGraph');
Result_dir = fullfile(root, 'PascalResult');
SynResult_dir = fullfile(root, 'SyntheticResult');
NoiseResult_dir = fullfile(root, 'NoiseResult');
LrResult_dir = fullfile(root, 'LandmarkRegistrationResult');
tmp_shapenet_dir = fullfile(root, 'ShapeNetMat.v1');
