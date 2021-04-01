
exp_root="exp/yolov2twobn_lr.005_batch128_subd16_dsize480_pretrain_s1.8_e1.8_h.2_a10_reanchor/"
data_path="data/zkysACT-v1.data"
cfg_train_path="cfg/yolov2-tiny-wobn-zkysACT-train.cfg"
cfg_train_bk="cfg_train_backup.cfg"
cfg_data_bk="zkysACT-v1.data"
cfg_test_bk="cfg_test_backup.cfg"
weight_pretrain="cfg/yolov3-tiny.conv.11"
weight_test_type="_best.weights"


test_video_root="D:/SWAP/record-videos/"
test_video_src_format=".mp4"
test_video_dst_fromat=".avi"
test_video_names[0]="20200923105421"
test_video_names[1]="20200923110017"
test_video_names[2]="20210302145240"
test_video_names[3]="20210302145416"
test_video_names[4]="20210302145950"
test_video_names[5]="20210302150107"
test_video_names[6]="20210302153303"
test_video_names[7]="20210319190203.record_1"
test_video_names[8]="20210319190203.record_2"
test_video_names[9]="20210319190203.record_3"
test_video_names[10]="20210319190203.record_4"
test_video_names[11]="20210319190203.record_5"

test_image_root="D:/SWAP/record-new/test_images"
test_image_save_name="test_images_save"

# make exp folder
if [ ! -d $exp_root ]; then
  mkdir $exp_root
fi

# copy data file and edit it
if [ ! -f $exp_root$cfg_data_bk ];then
    cp $data_path $exp_root$cfg_data_bk
    sed -i "5c backup = $exp_root" $exp_root$cfg_data_bk
fi

# copy train config file
if [ ! -f $exp_root$cfg_train_bk ];then
    cp $cfg_train_path $exp_root$cfg_train_bk
fi

# edit test config file from train config file
if [ ! -f $exp_root$cfg_test_bk ];then
    cp $exp_root$cfg_train_bk $exp_root$cfg_test_bk
    sed -i "3c batch=1" $exp_root$cfg_test_bk
    sed -i "4c subdivisions=1" $exp_root$cfg_test_bk
fi

# train
weight_test_path=$exp_root$cfg_train_bk$weight_test_type
weight_test_path=${weight_test_path/.cfg/}
if [ ! -f $weight_test_path ];then
    # open '-map' maybe cause 'cuDNN Error: CUDNN_STATUS_BAD_PARAM'
    if [ "$weight_pretrain" =  "" ]
    then
        ./darknet.exe detector train $exp_root$cfg_data_bk $exp_root$cfg_train_bk -map
    else
        ./darknet.exe detector train $exp_root$cfg_data_bk $exp_root$cfg_train_bk $weight_pretrain -map
    fi
fi

# move chart file
chart_name="chart_"$cfg_train_bk".png"
chart_name=${chart_name/.cfg/}
if [ -f ./$chart_name ] && [ ! -f $exp_root$chart_name ];then
    mv ./$chart_name $exp_root$chart_name
fi

# test videos
for video_name in ${test_video_names[@]};
do
    if [ ! -f $exp_root$video_name$test_video_src_format ];then
	    echo $video_name
        ./darknet.exe detector demo $data_path $exp_root$cfg_test_bk $weight_test_path $test_video_root$video_name$test_video_src_format -out_filename $exp_root$video_name$test_video_src_format
    fi
done

# test images
test_image_save_root=$exp_root$test_image_save_name
if [ ! -d $test_image_save_root ]; then
    mkdir $test_image_save_root
    python darknet_images.py --input $test_image_root --weight $weight_test_path --data_file $exp_root$cfg_data_bk --config_file $exp_root$cfg_train_bk --output $test_image_save_root --dont_show
fi

# valid testset
./darknet.exe detector map $data_path $exp_root$cfg_test_bk $weight_test_path
