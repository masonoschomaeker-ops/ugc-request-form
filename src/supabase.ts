import {createClient} from '@supabase/supabase-js';
const env=import.meta.env;
const url=env.VITE_SUPABASE_URL;
const key=env.VITE_SUPABASE_PUBLISHABLE_KEY;
function isPublicKey(value:string|undefined){
 if(!value)return false;
 if(value.startsWith('sb_publishable_'))return true;
 try{return JSON.parse(atob(value.split('.')[1].replace(/-/g,'+').replace(/_/g,'/'))).role==='anon'}catch{return false}
}
export const configured=!!url&&url.startsWith('https://')&&!url.includes('YOUR-PROJECT')&&isPublicKey(key);
export const supabase=configured?createClient(url,key):null;
export function client(){if(!supabase)throw Error('The form is not connected yet. The owner needs to configure Supabase with a public key.');return supabase;}
