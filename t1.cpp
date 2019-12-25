#include <stdio.h>
#include <stdlib.h>
typedef struct node *treePointer;
struct node {
	int data;
	treePointer left,right;
};
int predata[50];
int indata[50];
int leaf[50];
int ansLeaf;
int search(int arr[], int strt, int end, int value);
 treePointer buildTree(int in[], int pre[], int inStrt, int inEnd);
  treePointer newNode (int data);
  void findLeafNodes(treePointer root);
  void BubbleSort(int a[], int Size);
  void printLeaf(int a[],int size);
  void addAnsLeaf(int a);
int main()
{
	ansLeaf=0;
	treePointer root;
	int nNode=0;
	scanf("%d",&nNode);
	for(int i=0;i<nNode;i++)
	{
		scanf("%d",&predata[i]);
	}
	for(int i=0;i<nNode;i++)
	{
		scanf("%d",&indata[i]);
	}

	root=buildTree(indata,predata,0,nNode-1);
	findLeafNodes(root);
	BubbleSort(leaf,ansLeaf);
	printLeaf(leaf,ansLeaf);
	return 0;
 } 

 treePointer newNode (int data)
 {
 	treePointer temp=(treePointer)malloc(sizeof(treePointer));
 	temp->data=data;
 	temp->left=NULL;
 	temp->right=NULL;
 	return temp;
 } 
 treePointer buildTree(int in[], int pre[], int inStrt, int inEnd) 
{ 
    static int preIndex = 0;  
  
    if (inStrt > inEnd) 
        return NULL; 

    treePointer tNode = newNode(pre[preIndex++]); 

    if (inStrt == inEnd) 
        return tNode; 

    int inIndex = search(in, inStrt, inEnd, tNode->data); 
    tNode->left = buildTree(in, pre, inStrt, inIndex - 1); 
    tNode->right = buildTree(in, pre, inIndex + 1, inEnd); 
  
    return tNode; 
} 
int search(int arr[], int strt, int end, int value) 
{ 
    int i; 
    for (i = strt; i <= end; i++) { 
        if (arr[i] == value) 
            return i; 
    } 
} 
void findLeafNodes(treePointer root) 
{ 
    if (!root) 
        return; 
     
    if (!root->left && !root->right) 
    { 
        addAnsLeaf(root->data); 
        return; 
    } 

    if (root->left) 
       findLeafNodes(root->left); 

    if (root->right) 
       findLeafNodes(root->right); 
}
void BubbleSort(int a[], int Size)
{
    int i, j, temp;
    for (i = 0;i<(Size-1); ++i)
    {
        for (j=0;j<Size-1-i; ++j)
        {
            if (a[j]>a[j+1])
            {
                temp = a[j+1];
                a[j+1] = a[j];
                a[j] = temp;
            }
        }
    }
}
void addAnsLeaf(int a)
{
	leaf[ansLeaf++]=a;
}
void printLeaf(int a[],int size)
{
	for(int i=0;i<size;i++)
	{
		printf("%d",a[i]);
		if(i!=size-1)
		{
			printf(" ");
		}
	}
}
