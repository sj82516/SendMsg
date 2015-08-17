import controlP5.*;
import g4p_controls.*;
import processing.serial.*;
Serial port;
String inBuffer="";

ControlP5 cp5;
String name = "";
String phoneNum = "";

GTextArea txaSample;
String startText;
String content;

void setup() {
  size(540,400);
  PFont font = createFont("arial",20);
  cp5 = new ControlP5(this);
  
  cp5.addTextfield("input_num")
     .setPosition(20,40)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setAutoClear(false)
     .setColor(color(255,0,0))
     ;
  cp5.addTextfield("input_name")
     .setPosition(300,40)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setAutoClear(false)
     .setColor(color(255,0,0))
     ;
  String[] paragraphs = loadStrings("content.txt");
  startText = PApplet.join(paragraphs, '\n');

  // Create a text area with both horizontal and 
  // vertical scrollbars that automatically hide 
  // when not needed.
  txaSample = new GTextArea(this, 20, 100, 500, 200, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  txaSample.setText(startText, 400);
  
  cp5.addBang("send")
       .setPosition(380, 320)
       .setSize(140, 50)
       .setTriggerEvent(Bang.RELEASE)
       .setLabel("Send it!")
       ;
  port = new Serial(this,Serial.list()[2], 9600); 
  port.clear();
  textFont(font);
}

//This function is called when User finish key in data and press 'enter'
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    //change the content name to the input name, need to modify 'content.txt'
    if(theEvent.getName().equals("input_name")){
      name = theEvent.getStringValue();
      cp5.get(Textfield.class,"input_name").setColor(color(0,255,0));
      content = startText.replace("%name",name);
      txaSample.setText(content, 400);
    }
    //check whether the phone number is 10 digits or not 
    if(theEvent.getName().equals("input_num")){
      phoneNum = theEvent.getStringValue();
      if(phoneNum.length()!=10){
        cp5.get(Textfield.class,"input_num").setColor(color(255,0,0));
        cp5.get(Textfield.class,"input_num").clear();
      }else{
        cp5.get(Textfield.class,"input_num").setColor(color(0,255,0));
        phoneNum = theEvent.getStringValue();
      }
    }
  }
}

int sendingLevel = 0;
//when user click 'send' button
//Using Serial to communicate with Linkit one
//There are three steps to send data
//1 for check, 2 for phoneNum,3 for content,
//receiving A,B for step 1 and 2 succeed,C for send Msg succeed,D for fail
public void send() {
  while(name!=null && phoneNum!=null){
    port.write("check");
    if(port.available()>0){
      int buffer = port.read();
      port.clear();
      switch(sendingLevel){
        case 0:
          if(buffer==65){
            println("I got A");
            sendingLevel = 1;
            port.write(phoneNum);
            buffer = 0;
          }
          break;
        case 1:
          if(buffer==66){
            println("I got B");
            sendingLevel = 2;
            port.write(content);
            buffer = 0;
          }
          break;
        case 2:
          if(buffer==67){
            println("I got C");
            cp5.get(Textfield.class,"input_num").clear();
            cp5.get(Textfield.class,"input_name").clear();
            phoneNum = "";
            name = "";
            sendingLevel = 0;
            buffer = 0;
          }else if(buffer==68){
            println("I got D");
            cp5.get(Textfield.class,"input_num").clear();
            cp5.get(Textfield.class,"input_name").clear();
            phoneNum = "";
            name = "";
            sendingLevel = 0;
            buffer = 0;
          }
          break;
       }
    }
    port.clear();
  }
}


void draw() {
  background(0);
  fill(255);
  String tempName = cp5.get(Textfield.class,"input_name").getText();
  String tempNum = cp5.get(Textfield.class,"input_num").getText();
  //if user modify the name,the textarea will clean up
  if(!name.equals(tempName) && name.length()>tempName.length()){
    cp5.get(Textfield.class,"input_name").clear();
    cp5.get(Textfield.class,"input_name").setColor(color(255,0,0));
    name="";
  }
  //if user modify the phone number,the textarea will clean up
  if(!phoneNum.equals(tempNum) && phoneNum.length()>tempNum.length()){
    cp5.get(Textfield.class,"input_num").clear();
    cp5.get(Textfield.class,"input_num").setColor(color(255,0,0));
    phoneNum="";
  }
}
