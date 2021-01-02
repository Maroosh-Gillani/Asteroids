//declaring variables and arrays
float px, py, movementx, movementy, dis;

int state = 0;

int score = 0;

int lives = 3;

int health = 100;

//sound 
import processing.sound.*;
SoundFile laser;
SoundFile expsfx;

//laser
ArrayList<Float> lx = new ArrayList<Float>();
ArrayList<Float> ly = new ArrayList<Float>();
ArrayList<Float> lsx = new ArrayList<Float>();
ArrayList<Float> lsy = new ArrayList<Float>();
int lspeed = 10;

//asteroids
ArrayList<Float> ax = new ArrayList<Float>();
ArrayList<Float> ay = new ArrayList<Float>();
ArrayList<Float> asx = new ArrayList<Float>();
ArrayList<Float> asy = new ArrayList<Float>();

//special asteroids
ArrayList<Float> max = new ArrayList<Float>();
ArrayList<Float> may = new ArrayList<Float>();
ArrayList<Float> masx = new ArrayList<Float>();
ArrayList<Float> masy = new ArrayList<Float>();

//explosions
ArrayList<Integer> ex = new ArrayList<Integer>();
ArrayList<Integer> ey = new ArrayList<Integer>();
ArrayList<Float> a = new ArrayList<Float>();//percentage value for animation to work

void setup()
{
  size(800, 600);
  
  px = width/2;//player positions at the start
  py = height/2;

  laser = new SoundFile(this, "Laser.mp3");
  expsfx = new SoundFile(this, "Explosion+1.mp3");

  //asteroid spawn for loop. The i < 10 condition controls how many asteroids the game starts off with, in this case 10
  for (int i = 0; i < 10; i ++)
  {
    spawn();
  }

  //Special asteroid spawn loop
  for (int i = 0; i < 3; i ++)
  {
    spawn2();
  }
}

void draw()
{
  if (state == 0)//Game start up screen if statement
  {
    background(0);

    fill(255);
    stroke(0);
    strokeWeight(1);
    textSize(30);
    text("Asteroids by Maroosh Gillani", 200, 100);//Title

    rect(290, height/2 - 100, 250, 50);//Buttons
    rect(290, height/2, 250, 50);
    fill(100);
    text("Start Game", 335, height/2 - 65);
    text("Instructions", 330, height/2+35);
    
    //just some visuals
    fill(0,120,120);
    ellipse(width-100,height-100,50,50);//spaceship
    
    fill(255);
    ellipse(150,height/2+100,80,80);//asteroid
    
    stroke(255,0,0);
    strokeWeight(5);
    line(width-140,height-100,200,height/2+100);//laser
   
    line(200,height/2+90,220,height/2+80);//impact effect laser things
    line(200,height/2+110,220,height/2+120);
    line(195,height/2+80,220,height/2+50);
    line(195,height/2+120,220,height/2+150);
    
    fill(255,0,0);
    textSize(15);
    text("*pew*", width-140,height-130);//sound effects
    text("*pew*", width-100,height-60);
    fill(200,150,0);
    text("*boom bam bow*",50,height/2+55);
    text("*explode*", 120,height/2+155);
    
    stroke(0);
    strokeWeight(1);
  }

  if (state == 1)//within this if statement, all the gameplay stuff happens
  {

    background(0);

    //space ship
    fill(0, 120, 120);
    ellipse(px, py, 25, 25);

    fill(0, 240, 250);//score display
    textSize(40);
    text("Score:"+score, 10, 50);

    noFill();//health bar
    stroke(255);
    strokeWeight(2);
    rect(width-141, 19, 101, 22);
    stroke(0);
    strokeWeight(1);
    fill(0, 200, 50);
    rect(width-140, 20, health, 20);
    textSize(20);
    text("Health Bar:", width - 250, 40);

    fill(200, 0, 0);//lives display
    text("Lives: "+lives, width/2 - 30, 40);

    //horizontal boundaries for ship, allowing it to teleport to the other side when it moves off screen
    px = px + movementx;

    if (px > width - 25)
    {
      px = 0;
    } 
    else if (px < 0)
    {
      px = width - 25;
    }

    //vertical boundaries boundaries for ship, allowing it to teleport to the other side when it moves off screen
    py = py + movementy;

    if (py > height - 25)
    {
      py = 0;
    } 
    else if (py < 0)
    {
      py = height - 25;
    }

    //laser code for loop
    for (int i = 0; i < lx.size(); i++)
    {
      fill(255, 0, 0);
      rect(lx.get(i), ly.get(i), 5, 5);

      lx.set(i, lx.get(i) + lsx.get(i));//speed (lsx) added to make the laser movein the direction mouse is clicked
      ly.set(i, ly.get(i) + lsy.get(i));

      //When the laser hits the top left or bottom right corner of the screen, the score goes up by 100
      //I added this in because there is such a small chance of hitting the exact coordinates of the corners, that if someone got that lucky, they would automatically get 100 points
      if (dist(lx.get(i), ly.get(i), 0, 0)<1||dist(lx.get(i), ly.get(i), width, height)<1)
      {
        score = score + 100;
        lx.set(i, 1000.1);//move the laser off screen so 100 points aren't spammed, just given out once
      }
    }

    //asteroid drawing and boundaries code for loop
    for (int i = 0; i < ax.size(); i++)
    {
      fill(255);
      ellipse(ax.get(i), ay.get(i), 30, 30);//asteroid shape

      ax.set(i, ax.get(i) + asx.get(i));//same idea as laser movement, but instead the vertical and horizontal speed (set up in the spawn function) is random which makes the asteroids move in different directions at different speeds
      ay.set(i, ay.get(i) + asy.get(i));

      //horizontal boundaries for asteroids, same idea as the spaceship
      if (ax.get(i)<0)ax.set(i, width-1.5);
      else if (ax.get(i)>width&&ax.get(i)<(width+70))ax.set(i, 0.5);

      //vertical boundaries for asteroids, same idea as the spaceship
      if (ay.get(i)<0)ay.set(i, height-1.5);
      else if (ay.get(i)>height)ay.set(i, 0.5);

      if (dist(px, py, ax.get(i), ay.get(i)) < 20)//asteroid and ship collision
      {
        println("Ship hit asteroid");
        ax.set(i, 1000.1);//asteroid moved off screen so player doesn't keep losing health
        healthSystem();//health function, honestly just wanted to practice making functions
      }

      for (int j = 0; j <lx.size(); j++)//for loop to make laser and asteroid detection possible, as both array lists have different sizes. Tying both to 1 for loop = 1 variable = disaster
      {
        if (dist(lx.get(j), ly.get(j), ax.get(i), ay.get(i)) < 20)//Hit detection for laser and asteroid, when the distance between the laser and asteroid is less than 20, asteroid is moved off screen and explosion positions and percentage for the explosion is added
        {
          expsfx.play();
          ax.set(i, 1000.1);
          score = score + 1;//score goes up by 1 per asteroid destroyed
          ex.add(int(lx.get(j)));//laser position becomes explosion position on impact with asteroid
          ey.add(int(ly.get(j)));
          a.add(1.0);//animation percentage added
        }
      }
    }

    // asteroid clean up for loop
    for (int i = 0; i < ax.size(); i++)
    {
      if (ax.get(i) > 1000)//when asteroid is off screen at more than x = 1000, asteroid is removed
      {
        ax.remove(i);
        ay.remove(i);
      }
    }

    //Special asteroid drawing and boundaries code for loop and if statement
    if (score > 50)//Special asteroids will only show up when score has exceeded 50
    {
      for (int i = 0; i < max.size(); i++)
      {
        fill(200, 150, 0);

        ellipse(max.get(i), may.get(i), 50, 50);

        max.set(i, max.get(i) + masx.get(i));//same idea as normal asteroids, except the speed etc. is setup in another function ( spawn2() )
        may.set(i, may.get(i) + masy.get(i));

        //horizontal boundaries for special asteroids, same idea as the spaceship
        if (max.get(i)<0)max.set(i, width-1.5);
        else if (max.get(i)>width&&max.get(i)<(width+70))max.set(i, 0.5);

        //vertical boundaries for special asteroids, same idea as the spaceship
        if (may.get(i)<0)may.set(i, height-1.5);
        else if (may.get(i)>height)may.set(i, 0.5);

        if (dist(px, py, max.get(i), may.get(i)) < 50)//special asteroid and ship collision
        {
          println("Ship hit special asteroid");
          max.set(i, 1000.1);
          healthSystem2();
        }

        for (int j = 0; j <lx.size(); j++)//same idea as normal asteroid and laser collision
        {
          if (dist(lx.get(j), ly.get(j), max.get(i), may.get(i)) < 50)//Hit detection for laser and special asteroid
          {
            expsfx.play();
            max.set(i, 1000.1);
            score = score + 10;//increased score from special asteroid
            ex.add(int(lx.get(j)));
            ey.add(int(ly.get(j)));
            a.add(1.0);
          }
        }
      }

      for (int i = 0; i < max.size(); i++)//Special asteroids respawn
      {
        if (max.size() < 3)//whenever # of special asteroids goes below 3, it makes more special asteroids at random positions until 3 are present again
        {
          max.add(random(width));
          may.add(random(height));
        }
      }
    }

    //Special asteroid clean up for loop
    for (int i = 0; i < max.size(); i++)
    {
      if (max.get(i) > 1000)
      {
        max.remove(i);
        may.remove(i);
      }
    }

    //laser clean up for loop
    for (int i = 0; i < lx.size(); i++)
    {
      if (lx.get(i)<0||lx.get(i)>width||ly.get(i)<0||ly.get(i)>height)
      {
        lx.remove(i);
        ly.remove(i);
        lsx.remove(i);
        lsy.remove(i);
      }
    }

    for (int i = 0; i < ax.size(); i++)//asteroids respawn
    {
      if (ax.size() < 10)//whenever # of asteroids goes below 10, it makes more asteroids at random positions until 10 are present again
      {
        ax.add(random(width));
        ay.add(random(height));
      }
    }

    //explosion for loop
    for (int i=0; i < ex.size(); i++) 
    {
      fill(255*a.get(i), 100*a.get(i), 0);//colours multiplied by percentage as well so it fades out

      ellipse(ex.get(i), ey.get(i), 100*a.get(i), 100*a.get(i));//explosion, same idea as above with size

      a.set(i, a.get(i) - 0.01);//animation for how fast the explosion fades away as percentage is lowered
    }

    //clean up for loop -- explosion and percentage
    for (int i=0; i < ex.size(); i++) 
    {
      if (a.get(i) < 0.20)//when percentage gets super low
      {
        a.remove(i);//percentage removed
        ex.remove(i);//explosion positions removed
        ey.remove(i);
      }
    }
  }


  if (state == 2)//game over screen
  {
    background(0);
    textSize(30);
    fill(255);
    text("GAME OVER :(", 300, height/2);
    text("Your score: "+score, 300, height/2+40);//final score
    
    rect(width-220,height-70,200,50);//play again button 
    textSize(30);
    fill(100);
    text("Play Again?", width-200,height-35);
  }
  
  if (state == 3)//instructions screen
  {
    background(0);//actual instructions
    fill(255);
    textSize(20);
    text("Instructions/How to play:",10,40);
    text("- Arrow Keys to Move (player will accelerate, \narrow keys not being pressed does not mean no movement.) \n- Click to shoot lasers at asteroids, the lasers will go in the same direction \nas where mouse was clicked.\n- At 21 points, scatter shot powerup will be unlocked, \nat 51 points, asteroids that awards more points will be introduced, \nbut they will also deal more damage.\n- 1 white asteroid = 1 point, 1 special (gold) asteroid = 10 points.\n- If the laser hits 2 very specific secret spots on the screen, \n100 points will be awarded.\n-Player has 3 lives, each life is lost when health bar is depleted.\n- When life is lost, player will transport to the middle of the screen.\n- Enjoy!",10,80);
    
    rect(width-220,height-70,200,50);//play button 
    textSize(30);
    fill(100);
    text("Play", width-150,height-35);
  }
}

void keyPressed() 
{
  //spaceShip movement using keys
  if (keyCode == UP)
  {
    movementy -= 0.3;
  } 
  else if (keyCode == DOWN)
  {
    movementy += 0.3;
  } 
  else if (keyCode == LEFT)
  {
    movementx -= 0.3;
  } 
  else if (keyCode == RIGHT)
  {
    movementx += 0.3;
  }
}

void mousePressed()
{
  //Start game when Start Game Button clicked on Start Screen
  if (state == 0 && (mouseX > 290 && mouseX < (290+250) && mouseY > (height/2 - 100) && mouseY < (height/2 - 50)) )
  {
    state = 1;
  }
  //Go to instructions page when Instructions Button clicked on Start Screen
  if (state == 0 && (mouseX > 290 && mouseX < (290+250) && mouseY > (height/2) && mouseY < (height/2 + 50)) )
  {
    state = 3;
  }
  //Start game when Play button clicked on Instructions screen
  if (state == 3 && (mouseX > (width-220) && mouseX < (width-20) && mouseY > (height-70) && mouseY < (height-20)) )
  {
    state = 1;
  }
  //Start game when Play Again button clicked on Game Over Screen.
  if (state == 2 && (mouseX > (width-220) && mouseX < (width-20) && mouseY > (height-70) && mouseY < (height-20)) )
  {
    state = 1;
    lives = 3;//reset lives and score
    score = 0;
  }
  //Stuff that should only happen when the game portion is being played
  if (state == 1)
  {
    laser.play();//play sound mouse is clicked, which is only done when player wants to shoot lasers
    
    //laser movement
    dis = dist(mouseX, mouseY, px, py);

    float bx = mouseX - px;//using right angled triangles
    float by = mouseY - py;

    float spdx = bx/dis;//divided to get smaller similar triangle
    float spdy = by/dis;

    spdx = spdx*lspeed;
    spdy = spdy*lspeed;

    if (score <= 20)//shoots normal lasers when score is less than or equal to 20
    {
      lx.add(px);
      ly.add(py);
      lsx.add(spdx);
      lsy.add(spdy);
    }

    else//when score becomes higher than 20, scatter shot powerup comes in to play 
    {
      for (int i = 0; i < 5; i++)//scatter shot for loop -- allows 5 lasers to shoot out at once 
      {
        lx.add(px+random(50)-25);//the random part allows the scatter shot to happen. I learned that the higher the range of random numbers, the farther distcance between the lasers
        ly.add(py+random(50)-25);
        lsx.add(spdx);
        lsy.add(spdy);
      }
    }
  }
}

void healthSystem()
{
  health = health - 20;//each time asteroid hits, 20 hp lost
  println(health);
  if (health <= 0)//when health reaches 0, health is reset and life goes down by 1
  {
    posReset();//reset function comes into play when health reaches 0, or when life is lost.
    health = 100;
    lives = lives - 1;
  }

  if (lives == 0)//When no lives remaining, state becomes 2, which displays the game over screen
  {
    state = 2;
  }
}

void healthSystem2()
{
  health = health - 50;//each time Special asteroid hits, 50 hp lost
  println(health);
  if (health <= 0)//when health reaches 0, health is reset and life goes down by 1
  {
    health = 100;
    lives = lives - 1;
    posReset();//reset function comes into play when health reaches 0, or when life is lost.
  }

  if (lives == 0)//When no lives remaining, state becomes 2, which displays the game over screen
  {
    state = 2;
  }
}

void spawn()//spawn function for normal asteroids
{
  //generates random x and y values
  float x = random(width);
  float y = random(height);

  boolean check = false;

  if (dist(x, y, px, py)<100)//checks if the x and y values are near the player when game starts (asteroid and player)
  {
    check = true;
  }

  for (int i = 0; i < ax.size(); i++)
  {
    if (dist(x, y, ax.get(i), ay.get(i))<20)//checks if x and y values are near other asteroids when game starts (asteroid and asteroid)
    {
      check = true;
    }
  }

  while (check)//when the if statements above apply
  {
    x = random(width);//keeps assigning x and y values
    y = random(height);

    check = false;

    if (dist(x, y, px, py)<100)//makes the check happen again if the x and y values are still too close to the player
    {
      check = true;
    }

    for (int i = 0; i < ax.size(); i++)
    {
      if (dist(x, y, ax.get(i), ay.get(i))<20)//makes the checl happen again if the x and y values are still too close to other asteroids
      {
        check = true;
      }
    }
  }

  //assigns the x and y values to the asteroid x and asteroid y arraylists, which allows the game to start with the asteroids a safe distance  away from the player and eachother
  ax.add(x);
  ay.add(y);
  asx.add(random(-3, 3));//assigns random horizontal and vertical speeds to the asteroids to make them move in different directions with different speeds
  asy.add(random(-3, 3));
}

void spawn2()//spawn function for special asteroids, exact same logic and idea as the spawn() function
{
  float x2 = random(width);
  float y2 = random(height);

  boolean check2 = false;

  if (dist(x2, y2, px, py)<100)
  {
    check2 = true;
  }

  for (int i = 0; i < max.size(); i++)
  {
    if (dist(x2, y2, max.get(i), may.get(i))<20)
    {
      check2 = true;
    }
  }

  while (check2)
  {
    x2 = random(width);
    y2 = random(height);

    check2 = false;

    if (dist(x2, y2, px, py)<100)
    {
      check2 = true;
    }

    for (int i = 0; i < max.size(); i++)
    {
      if (dist(x2, y2, max.get(i), may.get(i))<20)
      {
        check2 = true;
      }
    }
  }

  max.add(x2);
  may.add(y2);
  masx.add(random(-5, 5));
  masy.add(random(-5, 5));
}

/*I only wanted the reset to happen when a life is lost, so this function is used in the healthSystem and healthSystem2 functions*/
void posReset()
{
  //send space ship to middle of screen, make the speed/movement values 0 in case the player was moving at the time life was lost
  px = width/2;
  py = height/2;
  movementx = 0;
  movementy = 0;

  //normal asteroid reset - clear everything and spawn 10 normal asteroids again
  ax.clear();
  ay.clear();
  asx.clear();
  asy.clear();
  for (int i = 0; i <10; i++)
  {
    spawn();
  }

  //special asteroid reset - clear everything and spawn 3 special asteroids again
  max.clear();
  may.clear();
  masx.clear();
  masy.clear();
  for (int i = 0; i < 3; i++)
  {
    spawn2();
  }
}
