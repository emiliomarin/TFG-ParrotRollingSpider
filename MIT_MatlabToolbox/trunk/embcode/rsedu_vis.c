//File: rsedu_vis.c
/*
* AUTHOR Fabian Riether
* CREATE DATE 2015/08/25
* PURPOSE This module takes care of processing images to reconstruct the drone's pose (needs specific landmark setup)
* SPECIAL NOTES
* ===============================
* Change History
* 2015/08/25 created
* ==================================
*/
#include "rsedu_vis.h"
/*
 * Reconstruccion de imagen
 */

//----------------------------------
// Procesamiento de imagenes
//----------------------------------

/*
 * @entrada buffer puntero a la imagen actual de la camara
 * La imagen es 160x120 pixeles en formato YUV, igual a 80x120 elementos de tipo 'pixel2_t'
 * Esta funcion recorre la imagen en busqueda la plataforma de aterrizaje
 *
 * Llamada 60 veces por segundo.
 */


void RSEDU_image_processing(void * buffer)
{
	static int counter = 0;

	//comunicacion
	static float vis_data[4];
	int status;
	static int vis_fifo;

	//variables de imagen
	int i,j;
	int row,col;
	float yuv[3];
    float rgb[3];
	int nx=80, ny=120;
	float feature_pps[3][4];
	static unsigned char matchLookup[128][128][128];

	//variables de camara
	float camerapos[3]; //@TODO static?
	float camerayaw; 	//@TODO static?

	//Image and Matching Thresholds
	static int filtersize = 5; 			//odd numbered! dummy for potential gaussian filter mask, etc.
	int pxls_ftr_min 	  = 5; 			//minimum required nr of detected pixels per landmark

    
	if (counter==1)
	{
		usleep(20000);
	}

	//Inicialiacion de comunicacion
	int fifo;
	if (FEAT_IMSAVE == 2)
	{
	u8 * raw = buffer;
	};
	pixel2_t *image = buffer;  

	/*
	 * PROGRAMA
	 */


	//ptiming - declare and start
	//------------
	long long start;
	static FILE *ptfile;
	ptimer_start(FEAT_TIME,counter,&(start));
	//------------


	//process control
	counter++;

	if (counter==1)
	{
		//ptiming - init file
		//------------
		ptimer_init(FEAT_TIME,__func__,&(ptfile),NULL);
		//------------

		printf("rsedu_vis(): Init fifo-communication...\n");

		//open fifo to dump visual position estimates to control code

		if( access( "/tmp/vis_fifo", F_OK ) != -1 )
		{
		printf("rsedu_vis(): SUCCESS POSVIS FIFO exists! \n");

		vis_fifo = open("/tmp/vis_fifo",O_WRONLY);
					if(vis_fifo)
					{
						vis_data[0] = -99.0;
						write(vis_fifo,(float*)(&vis_data),sizeof(vis_data));
						close(vis_fifo);
						printf("rsedu_vis(): SUCCESS opening POSVIS-fifo!\n");
					}
					else
					{
						printf("rsedu_vis(): ERROR opening POSVIS-fifo!\n");
					}
		}
		else
			{
				printf("rsedu_vis(): ERROR opening POSVIS-fifo!\n");
			}


		//load lookuptable for matching process
		if (FEAT_NOLOOK==0)
		{
			 FILE* data;
			 if ((data = fopen("/data/edu/params/lookuptable.dat", "rb")) == NULL)
			{
				printf("rsedu_vis(): ERROR opening lookupfile \n");
			}

			fread(matchLookup, sizeof(matchLookup), 1, data);
			fclose(data);
		}
       
	}



	//Deteccion de plataforma
	//------------

    // Se recorre la imagen analizando cada pixel y comparandolo con un umbral establecido.
    // Si el existen un numero de pixeles oscuros superior a 280 se decide que se ha encontrado la plataforma.
    // Se calcula tambien el centro de gravedad de la imagen

	 if ( (FEAT_POSVIS_RUN) && ((counter % 15)==0) &&(NULL!=image)) //@pseudo4Hz
	{



		int margin = (int)(filtersize-1)/4;
        
        margin = 0; //Probar
        
        float min = 300.0;
        int areaYUV = 0;
        //Inicializacion de momento
        int m00 = 0;
        int m10 = 0;
        int m01 = 0;
        //Recorremos la imagen
		for (j=0;j<ny;j++){
				for (i=0;i<nx;i++){
                    
						 row = margin+j;
						 col = margin+i;
						 //Valores YUV para el pixel
						 yuv[0] = (float)image[nx*row+col].y1;
						 yuv[1] = (float)image[nx*row+col].u;
						 yuv[2] = (float)image[nx*row+col].v;
                      
                         //Se convierte a RGB
                         rgb[0] = 1.164*(yuv[0] - 16) + 1.596*(yuv[2] - 128);
                         rgb[1] = 1.164*(yuv[0] - 16) - 0.813*(yuv[2] - 128) - 0.391*(yuv[1] - 128);
                         rgb[2] = 1.164*(yuv[0] - 16) + 2.018*(yuv[1] - 128);

                         
                         float media = (rgb[0] + rgb[2] + rgb[1])/3; //Nivel de gris
                         // Se espera un tiempo para empezar a tener en cuenta lo encontrado, post-despegue
                         if(counter >200){
                             if(media < 40){
                               m00 += 1;
                               m10 += row;
                               m01 += col;
                             }
                              if(yuv[0] < 30){
                               areaYUV+= 1;
                             }
                         }
                       

					 }//end inner image-for
				 }//end outer image-for

       // printf("Area RGB: %d ; Area YUV: %d \n",m00,a);
        if(m00>280){
         parar = 1;
         printf("Vision: Aterriza!\n");
        }
        // Centro de gravedad
        float ig = m10/m00;
        float jg = m01/m00;
        
//          if(parar && m00 != 0 ){
//             printf("Area: %i \n",m00);
//             float ig = m10/m00;
//             float jg = m01/m00;
//             //error[0] = jg - 60;//dx
//             //error[1] = ig - 40;//dy
//             printf("Centro de gravedad : %f - %f \n",ig,jg);
//             //Queremos poner el CG en el centro de la imagen para aterrizar
//             // (40,60) 
//          }
//         


		//reconstruct pose
		//-------------



	}

	 	 //-----------
	 	 //Instrucciones para streaming
	 	 //-----------

		/* 
          Copiar la imagen en una cola FIFO. Esta puede ser enviada a un ordenador remoto con simples comandos:

		Ejecutar en un terminal dentro del directorio del drone (telnet 192.168.1.1) :

		  while [ 1 ]; do cat /tmp/picture | nc 192.168.1.2 1234; done

		Ejecutar estos dos comandos en dos ventanas de terminal del ordenador remoto:

		  mkfifo /tmp/rollingspiderpicture ; while [ 1 ]; do nc -l 1234 > /tmp/rollingspiderpicture; done
		  mplayer -demuxer rawvideo -rawvideo w=160:h=120:format=yuy2 -loop 0 /tmp/rollingspiderpicture

		*/

	 //-----------

	 if ( (FEAT_IMSAVE == 2) && ((counter % 60)==0) && (NULL!=image) ) //@pseudo1Hz
	 {
		 	printf("image_proc(): Write image to fifo...\n");
			mkfifo("/tmp/picture",0777);
			fifo=open("/tmp/picture",O_WRONLY);
			if(fifo)
			{
				//char word = "asd";
				//write(fifo,word,320*120);
				write(fifo,buffer,320*120);
				close(fifo);
				usleep(5000);
			}

	 }

	 //save image
	 //-----------

	 if ( (FEAT_IMSAVE == 1) && ((counter % 6)==0) && (NULL!=image) ) //@10Hz
	 {
		    FILE* data;
		    char filename[15];

		    sprintf(filename,"/tmp/edu/imgs/img%i.bin",counter);
		   
		    mkdir("/tmp/edu", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
		    mkdir("/tmp/edu/imgs", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
		    if ( (data = fopen(filename, "wb")) == NULL )
		    {
		        printf("rsedu_vis(): ERROR opening img file\n");
		    }

		    fwrite(image, sizeof(pixel2_t) * 80*120, 1, data);
		    fclose(data);
		    usleep(5000);

	 }




	usleep(4000);

	//ptiming - store
	//----------
	ptimer_stopstore(FEAT_TIME, counter,start, ptfile);
	//----------


}
