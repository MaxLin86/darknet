import cv2
import os
import glob
import tqdm


def images_to_mp4(images_list, dst_name, fps=24, image_size=None):
    # images_list.sort(key=lambda x: int(x.split('_')[-2]))
    images_list.sort(key=lambda x: (int(x.split('_')[-2]), int(x.split('_')[-1][:-5])))
    # ttttt = images_list.sort(key=lambda x: int(x.split('_')[1]))
    if image_size is None:
        first_image = cv2.imread(images_list[0])
        image_size = (first_image.shape[1], first_image.shape[0])

    # 'mp4v' 生成mp4格式的视频, 'DIVX' 生成avi格式的视频
    video = cv2.VideoWriter(dst_name, cv2.VideoWriter_fourcc(*'mp4v'), fps, image_size)

    for filename in tqdm.tqdm(images_list):
        if os.path.exists(filename):
            video.write(cv2.imread(filename))
    video.release()


def main(src_root, dst_root, src_format, dst_format, fps):
    if not os.path.exists(dst_root):
        os.makedirs(dst_root)

    video_dirs = os.listdir(src_root)
    for vd in video_dirs:
        video_dir = os.path.join(src_root, vd)
        print('\nprocess in {}'.format(video_dir))
        dst_name = os.path.join(dst_root, vd + dst_format)
        if not os.path.isdir(video_dir):
            continue
        images_list = []
        for fm in src_format:
            ifm = os.path.join(video_dir, '*' + fm)
            images = glob.glob(ifm, recursive=True)
            images_list.extend(images)
        images_to_mp4(images_list, dst_name, fps)


if __name__ == "__main__":
    video_clips_root = 'D:\\SWAP\\record-new2\\record-new2-camera6mmFront1'
    save_root = 'D:\\SWAP\\record-new2\\record-new2-camera6mmFront1-mp4'
    src_format = ['.jpg', '.jpeg', 'png']
    dst_format = '.mp4'
    fps = 15.0
    main(video_clips_root, save_root, src_format, dst_format, fps)
