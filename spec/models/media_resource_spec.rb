require 'spec_helper'

describe MediaResource do

  describe '私有方法' do
    it '能够切分传入的路径' do
      MediaResource.split_path('/foo/bar/123').should == ['foo', 'bar', '123']
      MediaResource.split_path('/foo/bar').should == ['foo', 'bar']
      MediaResource.split_path('/foo').should == ['foo']
      MediaResource.split_path('/中国国宝大熊猫').should == ['中国国宝大熊猫']
    end

    it '对于传入的无效路径会抛出异常' do
      expect {
        MediaResource.split_path(nil)
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('')
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('/')
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('foo/bar')
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('//foo')
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('/ha///ha')
      }.to raise_error(MediaResource::InvalidPathError)

      expect {
        MediaResource.split_path('/fo\o')
      }.to raise_error(MediaResource::InvalidPathError)
    end
  end

  describe '资源操作' do

    before do
      MediaResource.create(
        :name   => '北极熊',
        :is_dir => true,
        :media_resources => [
          MediaResource.new(
            :name   => '企鹅',
            :is_dir => true,
            :media_resources => [
              MediaResource.new(:name => '兔斯基.jpg.gif', :is_dir => false),
              MediaResource.new(:name => '狗头.jpg', :is_dir => false)
            ]
          )
        ]
      )

      tmpfile = Tempfile.new('panda')
      tmpfile.write('hello world')

      MediaResource.create(
        :name   => '大熊猫',
        :is_dir => true,
        :media_resources => [
          MediaResource.new(
            :name => '三只熊猫.jpg', 
            :is_dir => false,
            :file_entity => FileEntity.new(:attach => tmpfile)
          ),
          MediaResource.new(
            :name => '倒挂.jpg', 
            :is_dir => false,
            :file_entity => FileEntity.new(:attach => tmpfile)
          ),
          MediaResource.new(:name => '这是寂寞.jpg', :is_dir => false)
        ]
      )

      MediaResource.create(:name => '宋亮.png', :is_dir => false)
      MediaResource.create(:name => '太极图.jpg', :is_dir => false)
      MediaResource.create(:name => '很多猫.jpg', :is_dir => false)
      MediaResource.create(:name => '月球.jpg', :is_dir => false)

      MediaResource.create(:name => '必胜客.txt', :is_dir => false, :is_removed => true)
      MediaResource.create(:name => '蓝蓝路.txt', :is_dir => false, :is_removed => true)
      MediaResource.create(:name => '可乐', :is_dir => true, :is_removed => true)
    end

    describe '获取资源' do
      it '传入的路径没有资源时，返回空' do
        MediaResource.get('/foo/bar/123').should == nil
        MediaResource.get('/foo/bar').should == nil
        MediaResource.get('/foo').should == nil
        MediaResource.get('/中国国宝大熊猫').should == nil
        MediaResource.get('/北极熊/HTC').should == nil
      end

      it '传入的路径有资源时，返回指定资源' do
        MediaResource.get('/北极熊').is_dir.should == true
        MediaResource.get('/北极熊/企鹅/兔斯基.jpg.gif').is_dir.should == false
        MediaResource.get('/宋亮.png').is_dir.should == false
      end

      it '传入无效路径时，返回空' do
        MediaResource.get('/').should == nil
        MediaResource.get('/fo\o/bar').should == nil
        MediaResource.get('/f//f').should == nil
      end

      it '传入的路径对应已经被删除的资源时，返回空' do
        MediaResource.get('/必胜客.txt').should == nil
        MediaResource.get('/可乐').should == nil

        MediaResource.get('/北极熊/企鹅/兔斯基.jpg.gif').should_not == nil
        MediaResource.get('/北极熊/企鹅/兔斯基.jpg.gif').remove
        MediaResource.get('/北极熊/企鹅/兔斯基.jpg.gif').should == nil

        MediaResource.get('/大熊猫').should_not == nil
        MediaResource.get('/大熊猫/这是寂寞.jpg').should_not == nil
        MediaResource.get('/大熊猫').remove
        MediaResource.get('/大熊猫').should == nil
        MediaResource.get('/大熊猫/这是寂寞.jpg').should == nil
      end
    end

    describe '创建资源' do
      describe '创建文件资源' do

        file = Tempfile.new('test')

        it '创建资源后应该可以拿到' do
          MediaResource.get('/酸梅汤.html').should == nil
          MediaResource.get('/红枣/绿豆.png').should == nil

          MediaResource.put('/酸梅汤.html', file)
          MediaResource.get('/酸梅汤.html').should_not == nil

          MediaResource.put('/红枣/绿豆.png', file)
          MediaResource.get('/红枣').is_dir.should == true
          MediaResource.get('/红枣/绿豆.png').is_dir.should == false
        end

        it '传入无效路径后，创建资源抛出异常' do
          expect {
            MediaResource.put(nil, file)
          }.to raise_error(MediaResource::InvalidPathError)

          expect {
            MediaResource.put('haha', file)
          }.to raise_error(MediaResource::InvalidPathError)

          expect {
            MediaResource.put('/', file)
          }.to raise_error(MediaResource::InvalidPathError)

          expect {
            MediaResource.put('/fo\o', file)
          }.to raise_error(MediaResource::InvalidPathError)
        end

        it '先删除一个资源，再针对同样的路径创建资源，资源可以取到，且资源总数不变' do
          MediaResource.get('/太极图.jpg').should_not == nil

          count = MediaResource.count
          removed_count = MediaResource.removed.count

          MediaResource.get('/太极图.jpg').remove
          MediaResource.count.should == count - 1
          MediaResource.removed.count.should == removed_count + 1

          MediaResource.put('/太极图.jpg', file)
          MediaResource.count.should == count
          MediaResource.removed.count.should == removed_count
        end

        it '可以以文件覆盖文件夹，覆盖时，文件夹下所有资源被删除' do
          MediaResource.get('/大熊猫').is_dir?.should == true
          MediaResource.get('/大熊猫/倒挂.jpg').is_file?.should == true
          MediaResource.get('/大熊猫/这是寂寞.jpg').is_file?.should == true

          MediaResource.put('/大熊猫', file)
          MediaResource.get('/大熊猫').is_file?.should == true
          MediaResource.get('/大熊猫/倒挂.jpg').should == nil
          MediaResource.get('/大熊猫/这是寂寞.jpg').should == nil
        end

        it '当创建深层文件资源时，父文件夹包含已被删除的文件夹资源，则创建后应是非删除状态' do
          MediaResource.get('/可乐').should == nil
          MediaResource.removed.root_res.find_by_name('可乐').should_not == nil

          MediaResource.get('/可乐/凉茶').should == nil

          MediaResource.put('/可乐/凉茶/白开水.zip', file)

          MediaResource.get('/可乐').is_dir?.should == true
          MediaResource.get('/可乐/凉茶').is_dir?.should == true
          MediaResource.get('/可乐/凉茶/白开水.zip').is_file?.should == true
        end

        it '当创建深层文件资源时，父文件夹是已存在的文件，则覆盖已存在的文件为文件夹' do
          MediaResource.get('/月球.jpg').is_file? == true

          MediaResource.put('/月球.jpg/花火/群星.ppt', file)

          MediaResource.get('/月球.jpg').is_dir? == true
          MediaResource.get('/月球.jpg').is_file? == false

          MediaResource.get('/月球.jpg/花火').is_dir? == true
          MediaResource.get('/月球.jpg/花火/群星.ppt').is_file? == true
        end

        it '当创建深层文件资源时，父文件夹是已删除的文件，则创建后应该是未删除的文件夹' do
          MediaResource.get('/必胜客.txt').should == nil
          MediaResource.removed.root_res.find_by_name('必胜客.txt').is_file? == true

          count = MediaResource.count
          removed_count = MediaResource.removed.count

          MediaResource.put('/必胜客.txt/星之所在.mp3', file)
          MediaResource.get('/必胜客.txt').should_not == nil
          MediaResource.get('/必胜客.txt').is_dir?.should == true
          MediaResource.get('/必胜客.txt/星之所在.mp3').is_file?.should == true

          MediaResource.count.should == count + 2        
          MediaResource.removed.count.should == removed_count - 1
        end
      end

      describe '创建文件夹资源' do
        it '当指定位置已经存在任何资源时，抛出异常' do
          MediaResource.get('/太极图.jpg').should be_is_file
          MediaResource.get('/大熊猫').should be_is_dir

          expect {
            MediaResource.create_folder('/太极图.jpg')
          }.to raise_error(MediaResource::RepeatedlyCreateFolderError)

          expect {
            MediaResource.create_folder('/大熊猫')
          }.to raise_error(MediaResource::RepeatedlyCreateFolderError)
        end

        it '当创建一个多级文件夹时，父文件夹被连带创建' do
          MediaResource.get('/当归').should == nil
          MediaResource.get('/当归/鹿茸').should == nil

          MediaResource.create_folder('/当归/鹿茸/人参')

          MediaResource.get('/当归').should_not == nil
          MediaResource.get('/当归/鹿茸').should_not == nil
          MediaResource.get('/当归/鹿茸/人参').should_not == nil
        end

        it '当创建一个多级文件夹时，父文件夹是已存在的文件，则将其覆盖' do
          MediaResource.get('/大熊猫/三只熊猫.jpg').is_file?.should == true

          MediaResource.create_folder('/大熊猫/三只熊猫.jpg/滚滚控')
          MediaResource.get('/大熊猫').is_dir?.should == true
          MediaResource.get('/大熊猫/三只熊猫.jpg').is_dir?.should == true
          MediaResource.get('/大熊猫/三只熊猫.jpg/滚滚控').is_dir?.should == true
        end

        it '当创建文件夹时，指定路径是一个已被删除的资源，创建文件夹后，资源总数不变' do
          MediaResource.get('/可乐').should == nil
          MediaResource.removed.root_res.find_by_name('可乐').should_not == nil

          count = MediaResource.count
          removed_count = MediaResource.removed.count

          MediaResource.create_folder('/可乐').should == MediaResource.get('/可乐')
          MediaResource.get('/可乐').should_not == nil
          MediaResource.removed.root_res.find_by_name('可乐').should == nil
          MediaResource.count.should == count + 1
          MediaResource.removed.count.should == removed_count - 1
        end

        it '当传入无效路径时，不创建任何资源，也不抛异常' do
          count = MediaResource.count
          removed_count = MediaResource.removed.count

          MediaResource.create_folder('/可\乐').should == nil
          MediaResource.create_folder(nil).should == nil
          MediaResource.create_folder('/').should == nil
          MediaResource.create_folder('nl').should == nil

          MediaResource.count.should == count
          MediaResource.removed.count.should == removed_count
        end
      end
    end

    describe '读取信息' do
      it '能够从资源读取路径信息' do
        MediaResource.find_by_name('狗头.jpg').path.should == '/北极熊/企鹅/狗头.jpg'
        MediaResource.find_by_name('兔斯基.jpg.gif').path.should == '/北极熊/企鹅/兔斯基.jpg.gif'
      end

      it '能够读取文件和文件夹资源的META信息' do
        MediaResource.get('/大熊猫').metadata(:list => false).should == {
          :bytes => 0,
          :is_dir => true,
          :path => '/大熊猫',
          :contents => []
        }

        MediaResource.get('/大熊猫').metadata(:list => true).should == {
          :bytes => 0,
          :is_dir => true,
          :path => '/大熊猫',
          :contents => [
            {
              :bytes => 11, 
              :is_dir => false, 
              :path => '/大熊猫/三只熊猫.jpg', 
              :mime_type => 'text/plain'
            },
            {
              :bytes => 11, 
              :is_dir => false, 
              :path => '/大熊猫/倒挂.jpg',
              :mime_type => 'text/plain'
            },
            {
              :bytes => 0, 
              :is_dir => false, 
              :path => '/大熊猫/这是寂寞.jpg',
              :mime_type => 'application/octet-stream'
            }
          ]
        }

        MediaResource.get('/大熊猫/三只熊猫.jpg').metadata.should == {
          :bytes => 11,
          :is_dir => false,
          :path => '/大熊猫/三只熊猫.jpg',
          :mime_type => 'text/plain'
        }
      end
    end

    describe '删除资源' do
      it '资源被删除后，fileops_time应该更新' do
        mr = MediaResource.get('/大熊猫/这是寂寞.jpg')
        mr.update_attributes(:fileops_time => 21.minutes.ago)

        fileops_time = mr.fileops_time

        mr.remove

        mr.should be_is_removed
        mr.fileops_time.should_not == fileops_time
      end
    end
  end

end
