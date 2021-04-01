import os
import glob
import random
import shutil
import tqdm


def copy_files_and_gen_txt_from_list(file_list, src_root, path_flag, txt_flag=False):
    dst_root = src_root[:src_root.rfind('\\')]
    dst_dir = os.path.join(dst_root, path_flag)
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
        if txt_flag:
            # for LF in windows
            fo = open(dst_dir + '.txt', "wb")
        for file in tqdm.tqdm(file_list):
            file_name = file.replace(os.path.join(src_root, ''), '').replace('\\', '_')
            dst_path = os.path.join(dst_dir, file_name)
            shutil.copyfile(file, dst_path)
            if txt_flag:
                line = dst_path + '\n'
                fo.write(line.encode())
        if txt_flag:
            fo.close()
    else:
        print('output folder already exists.')


def split_train_test(images_list, src_root):
    test_percent = 0.1
    train_list = []
    test_list = []
    for image in images_list:
        if random.random() < test_percent:
            test_list.append(image)
        else:
            train_list.append(image)
    copy_files_and_gen_txt_from_list(test_list, src_root, path_flag='test_images', txt_flag=True)
    copy_files_and_gen_txt_from_list(train_list, src_root, path_flag='train_images', txt_flag=True)


def main(src_root):
    collect_format = ['*.jpg', '*.jpeg', '*.png']
    images_list = []
    for fm in collect_format:
        ifm = os.path.join(src_root, '**', fm)
        images = glob.glob(ifm, recursive=True)
        images_list.extend(images)
    split_train_test(images_list, src_root)


if __name__ == '__main__':
    dataset_root = 'D:\\SWAP\\darknet\\build\\darknet\\x64\\data\\zkysACT\\data-select-v1'
    main(dataset_root)