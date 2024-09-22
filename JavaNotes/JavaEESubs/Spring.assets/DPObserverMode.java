// 观察者模式：https://www.w3cschool.cn/java/java-observer-pattern.html

abstract class Observer {

  protected MyObserver subject;
  public abstract void update();
  
}

class MyObserver {

  private List<Observer> observers = new ArrayList<Observer>();
  private int state;

  public int getState() {
    return state;
  }

  public void setState(int state) {
    this.state = state;
    notifyAllObservers();
  }

  public void attach(Observer observer) {
    observers.add(observer);
  }

  public void notifyAllObservers() {
    for (Observer observer : observers) {
      observer.update();
    }
  }

}

class PrinterObserver extends Observer {

  public PrinterObserver(MyObserver subject) {
    this.subject = subject;
    this.subject.attach(this);
  }

  @Override
  public void update() {
    System.out.println("Printer: " + subject.getState());
  }
}

class EmailObserver extends Observer {

  public EmailObserver(MyObserver subject) {
    this.subject = subject;
    this.subject.attach(this);
  }

  @Override
  public void update() {
    System.out.println("Email: " + subject.getState());
  }
}

class FileObserver extends Observer {

  public FileObserver(MyObserver subject) {
    this.subject = subject;
    this.subject.attach(this);
  }

  @Override
  public void update() {
    System.out.println("File: " + subject.getState());
  }
}

public class Main {

  public static void main(String[] args) {
    MyObserver subject = new MyObserver();

    new FileObserver(subject);
    new EmailObserver(subject);
    new PrinterObserver(subject);

    subject.setState(15);

    subject.setState(10);
  }
}
