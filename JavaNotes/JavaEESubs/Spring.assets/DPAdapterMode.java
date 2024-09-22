// 适配器模式：https://www.w3cschool.cn/java/java-adapter-pattern.html

interface Player {
   public void play(String type, String fileName);
}
interface AudioPlayer {  
   public void playAudio(String fileName);
}
interface VideoPlayer {  
   public void playVideo(String fileName);
}
class MyAudioPlayer implements AudioPlayer {
   @Override
   public void playAudio(String fileName) {
      System.out.println("Audio Playing. Name: "+ fileName);    
   }
}
class MyVideoPlayer implements VideoPlayer {
   @Override
   public void playVideo(String fileName) {
      System.out.println("Video Playing. Name: "+ fileName);    
   }
}

class MyPlayer implements Player {

   AudioPlayer audioPlayer = new MyAudioPlayer();
   VideoPlayer videoPlayer = new MyVideoPlayer();
   
   public MyPlayer(){      
   }
   @Override
   public void play(String audioType, String fileName) {
      if(audioType.equalsIgnoreCase("avi")){
         videoPlayer.playVideo(fileName);
      }else if(audioType.equalsIgnoreCase("mp3")){
         audioPlayer.playAudio(fileName);
      }
   }
}
public class Main{
   public static void main(String[] args) {
      MyPlayer myPlayer = new MyPlayer();

      myPlayer.play("mp3", "h.mp3");
      myPlayer.play("avi", "me.avi");
   }
}